class NistErrLoader < BaseLoader

  GEO_QUERY    = 'geo = ST_SimplifyPreserveTopology(ST_GeomFromKML(?), 0.0001)'
  MULTI        = '<MultiGeometry>%s</MultiGeometry>'

  TIE_COLOR    = 't0'
  NONPARTISAN  = 'nonpartisan'
  REPUBLICAN   = 'republican'
  DEMOCRATIC_1 = 'democratic-farmer-labor'
  DEMOCRATIC_2 = 'democratic'
  YES          = 'yes'
  FOR          = 'for'
  NO           = 'no'
  AGAINST      = 'against'


  def initialize(xml_source)
    @xml_source = xml_source
  end

  def load_results(locality_id)
    er = Vedaspace::Parser.parse_ved_file(@xml_source)
    status_report("Loaded parser from XML source")
    locality = Locality.find(locality_id)
    er_uid = er.issuer + " " + (er.election ? er.election.start_date : nil).to_s
    Election.transaction do
      election = Election.find_by_uid(er_uid)
      mismatches = {}

      # Pull in extra precinct data

      precinct_splits_voters = {}
      er.gp_units.each do |gp_unit|
        if gp_unit.is_a?(Vedaspace::ReportingUnit) && gp_unit.is_districted
          # skip it
        else
          if gp_unit.external_identifier_collection.external_identifiers.detect {|i| i.label == 'internal_id' }
            # It's a regular precinct
          else
            # Precinct split, add the reg-voters to i's parents
            name = "Precinct-Split-#{gp_unit.object_id.split('-').last}"
            precinct_splits_voters[gp_unit.object_id] = gp_unit.voters_registered
          end
        end
      end
      precinct_children = Precinct.includes(:precinct).where(uid: precinct_splits_voters.keys)
      precinct_parents = precinct_children.inject({}) do |h, pc|
        h[pc.uid] = pc.precinct || pc # may have sub-precinct, may not
        h
      end
      precinct_children.each do |p_child|
        reg_voters = precinct_splits_voters[p_child.uid].to_i
        p_parent = precinct_parents[p_child.uid]
        if p_parent
          p_parent.registered_voters = (p_parent.registered_voters || 0) + (reg_voters || 0)
        else
          raise p_child.uid.to_s
        end
      end
      precinct_parents.values.each do |p|
        p.save
      end


      if er.election
        er.election.tap do |e|
          #load candidates from the file
          ved_candidates = {}
          status_report "Loading Candidates from file"
          e.candidates.each do |c|
            ved_candidates[c.object_id] = c
          end

          # Load all the precincts into a hash
          status_report "Loading Precincts from Locality"
          locality_precincts = {}
          locality.precincts.all.each do |p|
            locality_precincts[p.uid] = p
          end
          status_report "Loading Parties from Locality"

          locality_parties = {}
          locality.parties.all.each do |p|
            locality_parties[p.uid] = p
          end
          write_in_party = nil

          # where is this in hart??
          #   election.election_type = e.type
          e.contests.each do |c|
            if c.is_a?(Vedaspace::CandidateContest)
              contest = election.contests.find_by_uid(c.object_id)
              status_report "Loading Results for #{contest.inspect}"

              #load pre-defined candidates
              status_report "Loading Candidates from DB"
              contest_candidates = {}
              contest.candidates.all.each do |can|
                contest_candidates[can.uid] = can
              end



              precinct_results = {}
              contest_response_results = {}

              (c.ballot_selections || []).each_with_index do |candidate_sel, i|
                
                candidate_uid = candidate_sel.ballot_selection_candidate_id_refs.first.candidate_id_ref
                
                candidate = contest_candidates[candidate_uid]  #it's just a UID
                # If it's a write-in, create it
                if candidate.nil? && candidate_sel.is_write_in

                  sel = ved_candidates[candidate_uid]
                  if sel.nil?
                    raise candidate_sel.candidate.first.to_s + ' ' + ved_candidates.inspect.to_s
                  end

                  write_in_party ||= locality.parties.create(:name=>"write-in", abbr: "write-in", uid: "write-in", sort_order:  locality_parties.size + 1 )
                  # TODO: write-in candidates have a party?
                  color = ColorScheme.candidate_pre_color(write_in_party.name)

                  candidate = Candidate.new(uid: sel.object_id,
                    name: sel.ballot_name.language_strings.first.text,
                    sort_order: candidate_sel.sequence_order,
                    party_id: write_in_party ? write_in_party.id : nil,
                    color: color)


                  contest.candidates << candidate

                end


                can_results = {}



                (candidate_sel.counts || []).each do |vc|
                  d_uid = vc.gp_unit_identifier #fix_district_uid(vc.gp_unit)
                  precinct = locality_precincts[d_uid]

                  if precinct
                    precinct = precinct.precinct || precinct
                    d_uid = precinct.uid
                    precinct_results[d_uid] ||= ContestResult.new(:uid=>"result-#{contest.uid}-#{precinct.uid}", :certification=>"unofficial_partial", precinct_id: precinct.id, contest_id: contest.id)
                  else
                    precinct_results[d_uid] ||= ContestResult.new(:uid=>"result-#{contest.uid}-#{d_uid}", :certification=>"unofficial_partial", contest_id: contest.id)
                  end

                  cr = precinct_results[d_uid]
                  cr.total_votes ||= 0
                  cr.total_valid_votes ||= 0
                  cr.undervotes ||= 0
                  cr.overvotes ||= 0
                  if precinct
                    cr.total_valid_votes += vc.count.to_i
                    can_result_uid = "#{contest.uid}-#{precinct.uid}-#{candidate.uid}-#{vc.count_item_type.to_s}"
                    can_res = can_results[can_result_uid]
                    if can_res.nil?
                      can_res = CandidateResult.new(candidate: candidate, precinct_id: precinct.id, uid: can_result_uid, votes: vc.count, ballot_type: vc.count_item_type.to_s)
                      can_results[can_result_uid] = can_res
                      contest_response_results[cr.uid] ||= []
                      contest_response_results[cr.uid] << can_res
                      cr.candidate_results << can_res
                    else
                      can_res.votes = (can_res.votes || 0) + (vc.count || 0)
                    end
                  else
                    mismatches[:precincts] ||= []
                    mismatches[:precincts] << d_uid
                    cr.total_valid_votes += vc.count.to_i
                    can_result_uid = "#{contest.uid}-no-precinct-#{candidate.uid}-#{vc.count_item_type.to_s}"
                    can_res = can_results[can_result_uid]
                    if can_res.nil?
                      can_res = CandidateResult.new(candidate: candidate, uid: can_result_uid, votes: vc.count, ballot_type: vc.count_item_type.to_s)
                      can_results[can_result_uid] = can_res
                      cr.candidate_results << can_res
                    else
                      can_res.votes = (can_res.votes || 0) + (vc.count || 0)
                    end
                  end
                  precinct_results[d_uid] = cr
                end

              end



              # at this point all ContestResults should be built
              # <SummaryCounts>
              #   <GpUnitId>vspub-reporting-unit-1</GpUnitId>
              #   <Type>total</Type>
              #   <BallotsCast>2061</BallotsCast>
              #   <Overvotes>0</Overvotes>
              #   <Undervotes>757</Undervotes>
              # </SummaryCounts>
              if c.summary_counts
                c.summary_counts.each do |sc|
                  d_uid = sc.gp_unit_identifier #fix_district_uid(vc.gp_unit)
                  precinct = locality_precincts[d_uid]

                  if precinct
                    precinct = precinct.precinct || precinct
                    d_uid = precinct.uid
                    cr = precinct_results[d_uid]
                    if cr.nil?
                      raise "No contest result for contest total count #{contest_total}"
                    end
                    cr.total_votes += sc.ballots_cast || 0
                    cr.undervotes += sc.undervotes || 0
                    cr.overvotes += sc.overvotes || 0
                  else
                    raise "No pct for contest summary count #{sc}"
                  end
                end
              end

              # Overall winner
              con_winners = {}
              precinct_results.values.each do |cr|
                cr.candidate_results.to_a.each do |can|
                  con_winners[can.candidate] ||= 0
                  con_winners[can.candidate] += can.votes.to_i
                end
              end
              top_cans = con_winners.to_a.sort {|a,b| b[1]<=>a[1] }.collect {|a| a[0]}

              precinct_results.values.each do |cr|
                if !cr.precinct_id.blank? && cr.candidate_results.size > 0
                  items = cr.candidate_results.to_a.sort {|a,b| b.votes.to_i <=> a.votes.to_i}
                  total_votes = cr.total_valid_votes || 0
                  diff = ((items[0].votes || 0) - (items[1].try(:votes) || 0)) * 100 / (total_votes == 0 ? 1 : total_votes)
                  leader = items[0].candidate

                  cr.color_code = self.candidate_color_code(leader, diff, total_votes, top_cans)
                  Rails.logger.warn(cr.color_code)
                end
              end

              status_report("Execute the contest import for #{contest.inspect}")

              ContestResult.import(precinct_results.values)
              contest_results = {}
              ContestResult.where(contest: contest).each do |cr|
                contest_results[cr.uid] = cr
              end
              all_results = []
              contest_response_results.each do |cr_uid, results|
                results.each do |res|
                  res.contest_result = contest_results[cr_uid]
                  all_results << res
                end
              end
              CandidateResult.import all_results

            elsif c.is_a?(Vedaspace::BallotMeasureContest)
              ref = locality.referendums.find_by_uid(c.object_id)
              if ref.nil?
                raise c.object_id
              end
              status_report "Loading results from referendum #{ref.inspect}"

              status_report "Pre-loading all ref responses"
              ref_responses = {}
              ref.ballot_responses.all.each do |r|
                ref_responses[r.uid] = r
              end

              precinct_results = {}
              ref_results = {}
              contest_response_results = {}

              c.ballot_selections.each_with_index do |sel, i|
                response = ref_responses[sel.object_id]
                raise sel.object_id.to_s if response.nil?
                (sel.counts || []).each do |vc|
                  d_uid =  vc.gp_unit_identifier

                  precinct = locality_precincts[d_uid]
                  if precinct
                    precinct = precinct.precinct || precinct
                    d_uid = precinct.uid
                    precinct_results[d_uid] ||= ContestResult.new(:uid=>"result-#{ref.uid}-#{precinct.uid}", :certification=>"unofficial_partial", precinct_id: precinct.id, referendum_id: ref.id, total_votes: 0)
                  else
                    raise 'abc'
                    precinct_results[d_uid] ||= ContestResult.new(:uid=>"result-#{ref.uid}-#{d_uid}", :certification=>"unofficial_partial", referendum_id: ref.id, total_votes: 0)
                  end

                  cr = precinct_results[d_uid]

                  cr.total_votes ||= 0
                  cr.total_valid_votes ||= 0
                  cr.undervotes ||= 0
                  cr.overvotes ||= 0

                  if precinct
                    cr.total_valid_votes += vc.count.to_i
                    ref_response_uid = "#{ref.uid}-#{precinct.uid}-#{response.uid}-#{vc.count_item_type.to_s}"
                    ref_res = ref_results[ref_response_uid]
                    if ref_res.nil?
                      ref_res = BallotResponseResult.new(ballot_response: response, precinct_id: precinct.id,
                      votes: vc.count, uid: ref_response_uid, ballot_type: vc.count_item_type.to_s)
                      ref_results[ref_response_uid] = ref_res
                      contest_response_results[cr.uid] ||= []
                      contest_response_results[cr.uid] << ref_res
                      cr.ballot_response_results << ref_res
                    else
                      ref_res.votes = (ref_res.votes || 0) + (vc.count || 0)
                    end
                  else
                    mismatches[:precincts] ||= []
                    mismatches[:precincts] << d_uid
                    cr.ballot_response_results << BallotResponseResult.new(ballot_response: response,
                      votes: vc.count, uid: "#{ref.uid}-no_precinct-#{response.uid}-#{vc.count_item_type.to_s}", ballot_type: vc.count_item_type.to_s)
                  end
                  precinct_results[d_uid] ||= cr
                end

              end

              # at this point all ContestResults should be built
              # TODO: what's the new equivalent?
              # c.contest_total_counts_by_gp_unit.each do |contest_total|
              #   d_uid = contest_total.gp_unit #fix_district_uid(vc.gp_unit)
              #   precinct = locality_precincts[d_uid]
              #
              #   # TODO: Remove this once vspub handles it better
              #   next if contest_total.ballots_cast.to_i == 0
              #
              #   if precinct
              #     precinct = precinct.precinct || precinct
              #     d_uid = precinct.uid
              #     cr = precinct_results[d_uid]
              #     if cr.nil?
              #       raise "No contest result for contest total count #{contest_total}"
              #     end
              #     cr.total_votes += contest_total.ballots_cast
              #     cr.undervotes += contest_total.undervotes
              #     cr.overvotes += contest_total.overvotes
              #   else
              #     raise "No pct for contest total count #{contest_total}"
              #   end
              # end

              precinct_results.values.each do |cr|
                if !cr.precinct_id.blank? && cr.ballot_response_results.size > 0
                  items = cr.ballot_response_results.to_a.sort {|a,b| b.votes.to_i <=> a.votes.to_i}
                  total_votes = cr.total_votes || 0
                  diff = ((items[0].votes || 0) - (items[1].try(:votes) || 0)) * 100 / (total_votes == 0 ? 1 : total_votes)
                  leader = items[0].ballot_response

                  cr.color_code = self.ballot_response_color_code(leader, diff, total_votes)
                end
              end

              status_report("Execute the contest import for #{ref.inspect}")
              ContestResult.import(precinct_results.values)

              contest_results = {}
              ContestResult.where(referendum_id: ref.id).each do |cr|
                contest_results[cr.uid] = cr
              end
              all_results = []
              contest_response_results.each do |cr_uid, results|
                results.each do |res|
                  res.contest_result = contest_results[cr_uid]
                  all_results << res
                end
              end
              BallotResponseResult.import all_results

            elsif c.is_a?(Vedaspace::PartyContest)
              # contest = Contest.new(uid: c.object_id,
              #   partisan: true,
              #   sort_order: c.sequence_order,)
              # contest.district = District.where(uid: c.contest_gp_scope).first
              # c.ballot_selection.each_with_index do |party_sel, i|
              #   party = Party.find_by_uid(party_sel)
              #
              #   color = ColorScheme.candidate_pre_color(party.name)
              #   candidate = Candidate.new(uid: party.uid,
              #     name: sel.ballot_name,
              #     sort_order: sel.sequence_order,
              #     party_id: party.id,
              #     color: color)
              #
              #   contest.candidates << candidate
              # end
              # locality.contests << contest
            end
          end
        end
      end

      locality.save!


      update_election(election, locality)

      election.save!


      return mismatches
    end
  end

  def candidate_color_code(candidate, diff, total_votes, top_cans)
    if diff == 0
      return TIE_COLOR
    else
      party = candidate.party.name.downcase
      if party == NONPARTISAN
        c=  '1'
        #c = sort_order == 1 ? '1' : '2'
      elsif party == REPUBLICAN
        c = 'r'
      elsif party == DEMOCRATIC_1 or party == DEMOCRATIC_2
        c = 'd'
      else
        if candidate.uid == top_cans[0].uid
          c = 'a'
        elsif candidate.uid == top_cans[1].uid
          c = 'b'
        elsif candidate.uid == top_cans[2].uid
          c = 'c'
        else
          c = 'o'
        end
        Rails.logger.warn("Setting #{c} for #{candidate.inspect} #{top_cans[0].inspect}")
        #c = candidate.color
      end

      return "#{c}#{shade(diff)}"
    end
  end
  def ballot_response_color_code(ballot_response, diff, total_votes)
    if diff == 0
      return TIE_COLOR
    else
      name, sort_order = ballot_response.name.downcase, ballot_response.sort_order
      if name == YES || name == FOR
        c = 'Y'
      elsif name == NO || name == AGAINST
        c = 'N'
      else
        c = sort_order == 1 ? 'Y' : 'N'
      end

      return "#{c}#{shade(diff)}"
    end
  end
  def shade(diff)
    if diff < AppConfig['map_color']['threshold']['lower']
      2
    elsif diff < AppConfig['map_color']['threshold']['upper']
      1
    else
      0
    end
  end

  def load(locality_id = nil)
    er = Vedaspace::Parser.parse_ved_file(@xml_source)
    Election.transaction do
      election = Election.new(uid: er_uid = er.issuer.to_s + " " + (er.election ? er.election.start_date : nil).to_s)
      # Election.where(uid: election.uid).destroy_all

      # TODO: shouldn't be required
      election.held_on = er.election && er.election.start_date ? er.election.start_date : Date.today
      election.state = State.find_by(code: (er.issuer_abbreviation || "CA"))

      # election.statewide = false # what does this mean ??


      election.election_type = er.election ? er.election.election_type.to_s : "pre-election" #"general"
      election.save!

      locality = nil
      if locality_id.nil?
        locality = create_locality(er.issuer, (er.issuer_abbreviation || "CA"), er.object_id)
      else
        locality = Locality.find(locality_id)
      end



      # first load up all the districts
      precinct_splits = {}
      locality_districts = {}
      locality_precincts = {}
      polygon_queries = {}
      er.gp_units.each do |gp_unit|
        if gp_unit.is_a?(Vedaspace::ReportingUnit) && gp_unit.is_districted
          # TODO: This is a temp "guesser" for the ID format to match existing ones
          type = case gp_unit.reporting_unit_type.to_s
          when Vedaspace::Enum::ReportingUnitType.congressional.to_s, Vedaspace::Enum::ReportingUnitType.state.to_s
            "Federal"
          when Vedaspace::Enum::ReportingUnitType.state_house.to_s, Vedaspace::Enum::ReportingUnitType.state_senate.to_s
            "State"
          when Vedaspace::Enum::ReportingUnitType.municipality.to_s, Vedaspace::Enum::ReportingUnitType.utility.to_s, Vedaspace::Enum::ReportingUnitType.water.to_s
            "MCD"
          when Vedaspace::Enum::ReportingUnitType.city.to_s, Vedaspace::Enum::ReportingUnitType.city_council.to_s, Vedaspace::Enum::ReportingUnitType.combined_precinct.to_s, Vedaspace::Enum::ReportingUnitType.county.to_s, Vedaspace::Enum::ReportingUnitType.county_council.to_s, Vedaspace::Enum::ReportingUnitType.judicial.to_s, Vedaspace::Enum::ReportingUnitType.precinct.to_s, Vedaspace::Enum::ReportingUnitType.school.to_s, Vedaspace::Enum::ReportingUnitType.split_precinct.to_s, Vedaspace::Enum::ReportingUnitType.town.to_s, Vedaspace::Enum::ReportingUnitType.township.to_s, Vedaspace::Enum::ReportingUnitType.village.to_s, Vedaspace::Enum::ReportingUnitType.ward.to_s
            "MCD"
          else
            "Other"
          end

          d = District.new({
            name:           gp_unit.name || gp_unit.object_id,
            district_type:  type,
            uid:            gp_unit.object_id,
            locality_id:    locality.id
          })
          puts d.uid

          locality_districts[d.uid] = d
          precinct_splits[d.uid] ||= { districts: [], precincts: [] }
          # precinct_splits[d.uid][:districts] << d
          (gp_unit.gp_unit_composing_gp_unit_id_refs || []).each do |sub_gp_id|
            #sub_gp_id = sib#fix_district_uid(sub_gp_id)
            ref_id = sub_gp_id.composing_gp_unit_id_ref
            precinct_splits[ref_id] ||= { districts: [], precincts: [] }
            precinct_splits[ref_id][:districts] << d
          end
          if !d.valid?
            raise d.errors.join("\n")
          end
        else
          p = nil
          name = gp_unit.name
          # if gp_unit.is_a?(Vedaspace::ReportingUnit)
          #   name = "Precinct-#{gp_unit.name}"
          # else
          #   # Precinct split
          #   name = "Precinct-Split-#{gp_unit.object_id}"
          # end

          p = Precinct.new({
            uid:          gp_unit.object_id,
            name:         name.blank? ? gp_unit.object_id : name ,
            locality_id:  locality.id
          })

          locality_precincts[p.uid] = p
          (gp_unit.gp_unit_composing_gp_unit_id_refs || []).each do |sub_gp_id|
            #sub_gp_id = fix_district_uid(sub_gp_id)
            ref_id = sub_gp_id.composing_gp_unit_id_ref
            precinct_splits[ref_id] ||= { districts: [], precincts: [] }
            precinct_splits[ref_id][:precincts] << p
          end

          # save KML for future bulk update
          polygons = []
          if gp_unit.respond_to?(:spatial_dimension) && gp_unit.spatial_dimension
            spatial_xml = gp_unit.spatial_dimension.spatial_extent.coordinates.to_s
            doc = Nokogiri::XML(spatial_xml.gsub("<![CDATA[",'').gsub(']]>',''))
            doc.css("Polygon").each do |p|
              p2 = p.to_s.gsub(/(-?\d+\.\d+,-?\d+\.\d+),-?\d+\.\d+/, '\1')
              polygons << p2
            end
            polygon_queries[p.uid] = polygons
          end
        end
      end

      District.import locality_districts.values

      # reload all the districts
      locality_districts = {}
      District.where(locality: locality).all.each do |d|
        locality_districts[d.uid] = d
      end
      
      Precinct.import locality_precincts.values

      # reload all the precincts
      locality_precincts = {}
      Precinct.where(locality: locality).all.each do |p|
        locality_precincts[p.uid] = p
      end
      

      # precinct splits are subrefs of any gpunits in the form
      # oid=>[districts], [children]
      # the oid *may* actually be a precinct
      precinct_splits.each do |split, parent_gpunits|
        p_split = locality_precincts[split]
        if p_split && p_split.name =~ /precinct-split/i
          parent_gpunits[:precincts].each do |p|
            p_obj = locality_precincts[p.uid]
            p_split.update_attributes(precinct_id: p_obj.id) unless p_split.uid == p.uid
          end
        end
      end

      # precinct splits are subrefs of any gpunits in the form
      # oid=>[districts], [children]
      # the oid *may* actually be a precinct
      district_precincts = []
      precinct_splits.each do |split, matched_gpus|
        matched_gpus[:districts].each do |d|
          if matched_gpus[:precincts].any?
            matched_gpus[:precincts].each do |p|
              district_precincts << DistrictsPrecinct.new(
                precinct: locality_precincts[p.uid],
                district: locality_districts[d.uid]
              )
            end
          elsif locality_precincts[split]
            raise d.inspect if locality_districts[d.uid].nil?
            district_precincts << DistrictsPrecinct.new(
              precinct: locality_precincts[split],
              district: locality_districts[d.uid]
            )
          else
            raise Precinct.count.to_s + ' ' + [split, matched_gpus].inspect.to_s
          end
        end
      end
      DistrictsPrecinct.import district_precincts

      polygon_queries.each do |uid, polygons|
        kml = (DataLoader::MULTI % polygons.join).gsub(',0 ', ' ').gsub(',0<', '<')
        Precinct.where(locality: locality, uid: uid).update_all([ DataLoader::GEO_QUERY, kml ])
      end






      locality_parties = {}
      if er.parties
        er.parties.each_with_index do |p,i|
          name = p.name.language_strings.first.text
          name = p.abbreviation if name.blank?
          existing_party = Party.where(uid: p.object_id, locality_id: locality.id)
          if !existing_party.any?
            new_party =  Party.new(uid: p.object_id, name: name, sort_order: i, abbr: p.abbreviation || p.object_id, locality_id: locality.id)
            locality_parties[p.object_id] = new_party

          end
        end
      end
      before = Party.count
      Party.import(locality_parties.values)
      locality_parties = {}
      Party.where(locality_id: locality.id).all.each do |p|
        locality_parties[p.uid] = p
      end


      offices = {}
      (er.offices || []).each do |o|
        offices[o.object_id] = o
      end
      mismatches = {}

      locality_contests = {}
      locality_referendums = {}

      contest_candidates = {}
      ref_responses = {}

      if er.election
        er.election.tap do |e|
          candidates = {}
          (e.candidates || []).each do |c|
            candidates[c.object_id] = c
          end

          # where is this in hart??
          #   election.election_type = e.type
          (e.contests || []).each do |c|
            if c.is_a?(Vedaspace::CandidateContest)
              
              contest_office = c.contest_office_id_refs && c.contest_office_id_refs.any? && offices[c.contest_office_id_refs.first.office_id_ref] ? offices[c.contest_office_id_refs.first.office_id_ref].name.language_strings.first.text : nil
              contest_office ||= c.name #.language_strings.first.text
              contest = Contest.new(uid: c.object_id, election: election, locality_id: locality.id,
                office: contest_office,
                sort_order: c.sequence_order)

              contest.district = locality_districts[c.electoral_district_identifier]
              if contest.district.nil?
                raise c.electoral_district_identifier.to_s + ' - ' + c.object_id
                mismatches[:districts] ||= []
                mismatches[:districts] << c.contest_gp_scope
              end

              if c.ballot_selections
                c.ballot_selections.each_with_index do |candidate_sel, i|
                  sel = candidates[candidate_sel.ballot_selection_candidate_id_refs.first.candidate_id_ref]
                
                  next if !sel || candidate_sel.is_write_in #TODO: don't know write-in party_ids
                
                  #TODO: can be multiple candidates in NIST ERR
                  color = nil
                  
                  party = locality_parties[sel.party_identifier] || Party.no_party(locality)

                  if party.nil? && !candidate_sel.is_write_in
                    raise sel.inspect.to_s + ' ' + locality.parties.collect(&:uid).to_s
                  end

                  color = party ? ColorScheme.candidate_pre_color(party.name) : nil
                  
                  candidate = Candidate.new(uid: sel.object_id,
                    name: sel.ballot_name.language_strings.first.text,
                    sort_order: candidate_sel.sequence_order,
                    party_id: party ? party.id : nil,
                    color: color)

                  contest_candidates[contest.uid] ||= []
                  contest_candidates[contest.uid] << candidate

                end
              end
              locality_contests[contest.uid] = contest
            elsif c.is_a?(Vedaspace::BallotMeasureContest)
              ref = Referendum.new(uid: c.object_id, locality_id: locality.id,
                sort_order: c.sequence_order,
                title: c.name,
                subtitle: c.summary_text && c.summary_text.language_strings.any? ? c.summary_text.language_strings.first.text : '',
                question: c.full_text  && c.full_text.language_strings.any? ? c.full_text.language_strings.first.text : '')

              ref.district = locality_districts[c.electoral_district_identifier]
              if ref.district.nil?
                raise c.electoral_district_identifier.to_s
                mismatches[:districts] ||= []
                mismatches[:districts] << c.contest_gp_scope
              end
              if c.ballot_selections
                c.ballot_selections.each_with_index do |sel, i|
                  response = BallotResponse.new(uid: sel.object_id,
                    name: (sel.selection && sel.selection.language_strings.any? ? sel.selection.language_strings.first.text : ''), 
                    sort_order: i+1)

                  ref_responses[ref.uid] ||= []
                  ref_responses[ref.uid] << response

                end
              end
              locality_referendums[ref.uid] = ref
            elsif c.is_a?(Vedaspace::PartyContest)
              # contest = Contest.new(uid: c.object_id,
              #   partisan: true,
              #   sort_order: c.sequence_order,)
              # contest.district = District.where(uid: c.contest_gp_scope).first
              # c.ballot_selection.each_with_index do |party_sel, i|
              #   party = Party.find_by_uid(party_sel)
              #
              #   color = ColorScheme.candidate_pre_color(party.name)
              #   candidate = Candidate.new(uid: party.uid,
              #     name: sel.ballot_name,
              #     sort_order: sel.sequence_order,
              #     party_id: party.id,
              #     color: color)
              #
              #   contest.candidates << candidate
              # end
              # locality.contests << contest
            end
          end
        end
      end

      #.import doesn't execut before-saves
      locality_contests.values.each do |c|
        c.run_callbacks(:save) { false }
      end
      Contest.import locality_contests.values
      locality_contests = {}
      Contest.where(locality: locality). each do |c|
        locality_contests[c.uid] = c
      end
      all_candidates = []
      contest_candidates.each do |contest_uid, candidates|
        candidates.each do |cand|
          cand.contest = locality_contests[contest_uid]
          all_candidates << cand
        end
      end
      Candidate.import(all_candidates)


      Referendum.import locality_referendums.values
      locality_referendums = {}
      Referendum.where(locality: locality). each do |r|
        locality_referendums[r.uid] = r
      end
      all_responses = []
      ref_responses.each do |ref_uid, responses|
        responses.each do |resp|
          resp.referendum = locality_referendums[ref_uid]
          all_responses << resp
        end
      end
      
      BallotResponse.import(all_responses)

      election.save!

      return mismatches
    end

  end

  private

  def fix_district_uid(d_uid)
    # TODO: This is a temp "guesser" for the ID format to match existing ones
    w = 'district'
    if d_uid =~ /precinct-\d/
      w = 'precinct'
    elsif d_uid =~ /district-\d/
      w = 'district'
    else
      return d_uid
    end
    d_id = d_uid.gsub(/#{w}-/,'')
    num_zeros = 4 - d_id.size
    if num_zeros > 0
      num_zeros.times do
        d_id = "0#{d_id}"
      end
      d_uid = "#{w}-#{d_id}"
    end
    return d_uid
  end

  def update_election(election, locality)
    # Calculate reporting percent
    all       = locality.precincts.where(precinct_id: nil).pluck(:id)
    reporting = BallotResponseResult.where(precinct_id: all).select("DISTINCT precinct_id").map(&:precinct_id)
    reporting << CandidateResult.where(precinct_id: all).select("DISTINCT precinct_id").map(&:precinct_id)
    reporting = reporting.flatten.uniq.count

    Rails.logger.info "----#{reporting} / #{all.count}"
    election.reporting = reporting * 100.0 / [ all.count, 1 ].max
    election.seq += 1
  end

  def create_locality(name, state_abbreviation, uid)
    state = State.find_by_code(state_abbreviation)
    return Locality.create(name: name, locality_type: "County", state: state, uid: uid)
  end

  def status_report(message)
    Rails.logger.info "LOADING: #{message}"
  end

end
