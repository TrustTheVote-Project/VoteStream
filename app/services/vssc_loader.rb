require 'vssc'
class VSSCLoader < BaseLoader
  
  GEO_QUERY                   = 'geo = ST_SimplifyPreserveTopology(ST_GeomFromKML(?), 0.0001)'
  MULTI                       = '<MultiGeometry>%s</MultiGeometry>'
  
  TIE_COLOR                       = 't0'  
  NONPARTISAN                     = 'nonpartisan'
  REPUBLICAN                      = 'republican'
  DEMOCRATIC_1                    = 'democratic-farmer-labor'
  DEMOCRATIC_2                    = 'democratic'
  YES                             = 'yes'
  NO                              = 'no'


  def initialize(xml_source)
    @xml_source = xml_source
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
  public
  
  def create_locality(name, state_abbreviation, uid)
    state = State.find_by_code(state_abbreviation)
    return Locality.create(name: name, locality_type: "County", state: state, uid: uid)
  end
  
  def load_results(locality_id)
    er = ::VSSC::Parser.parse(@xml_source)
    locality = Locality.find(locality_id)
    Election.transaction do
      election = Election.find_by_uid(er.object_id + '-vssc')
      mismatches = {}
      
      if er.election && er.election.first
        er.election.first.tap do |e|
          candidates = {}
          e.candidate_collection.candidate.each do |c|
            candidates[c.object_id] = c
          end
        
          # where is this in hart??
          #   election.election_type = e.type
          e.contest_collection.contest.each do |c|
            if c.is_a?(VSSC::CandidateChoice)
              contest = election.contests.find_by_uid(c.object_id)

              precinct_results = {}
            
              c.ballot_selection.each_with_index do |candidate_sel, i|
                
                #TODO: skip write-ins
                next if candidate_sel.is_write_in
                
                
                candidate = contest.candidates.find_by_uid(candidate_sel.candidate.first)
                # If it's a write-in, create it
                if candidate.nil? && candidate_sel.is_write_in
                  sel = candidates[candidate_sel.candidate.first] #TODO: can be multiple candidates in VSSC
                  party = Party.where(uid: sel.party, locality_id: locality.id).first
                  # TODO: write-in candidates have a party?
                  color = ColorScheme.candidate_pre_color(party.name)
                  
                  candidate = Candidate.new(uid: sel.object_id, 
                    name: sel.ballot_name, 
                    sort_order: sel.sequence_order, 
                    party_id: party ? party.id : nil, 
                    color: color)
              
                  contest.candidates << candidate
                  
                end


                candidate_sel.vote_counts.each do |vc|
                  if vc.ballot_type == VSSC::BallotType.election_day
                    d_uid = vc.gp_unit #fix_district_uid(vc.gp_unit)
                    precinct = locality.precincts.find_by_uid("#{d_uid}")
                  
                    if precinct
                      precinct = precinct.precinct || precinct
                      d_uid = precinct.uid
                      precinct_results[d_uid] ||= ContestResult.new(:uid=>"result-#{contest.uid}-#{precinct.uid}", :certification=>"unofficial_partial", precinct_id: precinct.id)
                    else
                      precinct_results[d_uid] ||= ContestResult.new(:uid=>"result-#{contest.uid}-#{d_uid}", :certification=>"unofficial_partial")
                    end
                
                    cr = precinct_results[d_uid]
                    cr.total_votes ||= 0
                    if precinct
                      cr.total_votes += vc.count
                      uid = "#{contest.uid}-#{precinct.uid}-#{candidate.uid}"
                      can_res = cr.candidate_results.find_by_uid(uid)
                      if can_res.nil?
                        can_res = CandidateResult.new(candidate: candidate, precinct_id: precinct.id, uid: "#{contest.uid}-#{precinct.uid}-#{candidate.uid}", votes: vc.count)
                        cr.candidate_results << can_res
                      else
                        can_res.votes = (can_res.votes || 0) + vc.count
                        can_res.save!
                      end
                    else
                      mismatches[:precincts] ||= []
                      mismatches[:precincts] << d_uid
                      cr.total_votes += vc.count
                      cr.candidate_results << CandidateResult.new(candidate: candidate,
                        votes: vc.count, uid: "#{contest.uid}-#{d_uid}-#{candidate.uid}")
                    end
                    cr.save!
                    precinct_results[d_uid] = cr
                  end
                  
                end
                
              end
              
              precinct_results.values.each do |cr|
                if !cr.precinct_id.blank? && cr.candidate_results.count > 0
                  items = cr.candidate_results.order("votes DESC").all
                  total_votes = cr.total_votes || 0
                  diff = (items[0].votes - (items[1].try(:votes) || 0)) * 100 / (total_votes == 0 ? 1 : total_votes)
                  leader = items[0].candidate

                  cr.color_code = self.candidate_color_code(leader, diff, total_votes)
                end
              end
              
              contest.contest_results = precinct_results.values
              
              
              
            
            elsif c.is_a?(VSSC::BallotMeasure)
              ref = locality.referendums.find_by_uid(c.object_id)
              if ref.nil?
                raise c.object_id
              end
              precinct_results = {}
            
              c.ballot_selection.each_with_index do |sel, i|
                response = ref.ballot_responses.find_by_uid(sel.object_id)

                sel.vote_counts.each do |vc|
                  d_uid =  vc.gp_unit #fix_district_uid(vc.gp_unit)
                  
                  precinct = Precinct.find_by_uid("#{d_uid}")
                  
                  if precinct
                    precinct = precinct.precinct || precinct
                  
                    precinct_results[d_uid] ||= ContestResult.new(:uid=>"result-#{ref.uid}-#{precinct.uid}", :certification=>"unofficial_partial", precinct_id: precinct.id)
                  else
                    precinct_results[d_uid] ||= ContestResult.new(:uid=>"result-#{ref.uid}-#{d_uid}", :certification=>"unofficial_partial")
                  end
                
                  cr = precinct_results[d_uid]
                
                  if precinct
                    cr.ballot_response_results << BallotResponseResult.new(ballot_response: response, precinct_id: precinct.id,
                      votes: vc.count, uid: "#{ref.uid}-#{precinct.uid}-#{response.uid}")
                  else
                    mismatches[:precincts] ||= []
                    mismatches[:precincts] << d_uid
                    cr.ballot_response_results << BallotResponseResult.new(ballot_response: candidate,
                      votes: vc.count, uid: "#{ref.uid}-#{d_uid}-#{response.uid}")
                  end
                  precinct_results[d_uid] ||= cr
                
                end
              
              end
              ref.contest_results = precinct_results.values
            
            elsif c.is_a?(VSSC::StraightParty)
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
      
      
      election.save!
      
      
      return mismatches
    end
  end
    
  def candidate_color_code(candidate, diff, total_votes)
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
        c = 'o'
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
    er = ::VSSC::Parser.parse(@xml_source)
    Election.transaction do
      election = Election.new(uid: er.object_id + '-vssc')
      Election.where(uid: election.uid).destroy_all
      
      election.held_on = er.date
      election.state = State.find_by(code: er.state_abbreviation)

      # election.statewide = false # what does this mean ??

      
      election.election_type = "general"
      
      if locality_id.nil?
        locality = create_locality(er.issuer, er.state_abbreviation, er.object_id)
      else
        locality = Locality.find(locality_id)
      end

      
      # first load up all the districts
      precinct_splits = {}
      er.gp_unit_collection.gp_unit.each do |gp_unit|
        if gp_unit.is_a?(VSSC::District)
          # TODO: This is a temp "guesser" for the ID format to match existing ones
          type = case gp_unit.district_type
          when VSSC::DistrictType.congressional
            "Federal"
          when VSSC::DistrictType.state_house, VSSC::DistrictType.state_senate, VSSC::DistrictType.statewide
            "State"
          when VSSC::DistrictType.locality
            "MCD"
          else
            "Other"
          end
          d = District.new(name: gp_unit.name, district_type: type, uid: gp_unit.object_id)
          locality.districts << d
          if d
            precinct_splits[d.uid] ||= {:districts=>[], :precincts=>[]}
            precinct_splits[d.uid][:districts] << d
            gp_unit.gp_sub_unit_ref.each do |sub_gp_id|
              sub_gp_id = fix_district_uid(sub_gp_id)
              precinct_splits[sub_gp_id] ||= {:districts=>[], :precincts=>[]}
              precinct_splits[sub_gp_id][:districts] << d
            end
          end
          d.save!
        else
          p = nil
          if gp_unit.local_geo_code
            p = Precinct.new({
              uid: gp_unit.object_id, 
              name: "Precinct-#{gp_unit.local_geo_code}"
            })
          else
            # precinct split
            p = Precinct.new({
              uid: gp_unit.object_id, 
              name: "Precinct-Split-#{gp_unit.local_geo_code}"
            })
          end
          
          
          locality.precincts << p
          if p
            #precinct_splits[p.uid] ||= {:districts=>[], :precincts=>[]}
            #precinct_splits[p.uid][:precincts] << p 
            gp_unit.gp_sub_unit_ref.each do |sub_gp_id|
              sub_gp_id = fix_district_uid(sub_gp_id)
              precinct_splits[sub_gp_id] ||= {:districts=>[], :precincts=>[]}
              precinct_splits[sub_gp_id][:precincts] << p
            end
          end
          p.save!
          
          polygons = []
          if gp_unit.spatial_dimension.any?
            spatial_xml = gp_unit.spatial_dimension.first.spatial_extent.coordinates.to_s
            doc = Nokogiri::XML(spatial_xml.gsub("<![CDATA[",'').gsub(']]>',''))
            doc.css("Polygon").each do |p|
              p2 = p.to_s.gsub(/(-?\d+\.\d+,-?\d+\.\d+),-?\d+\.\d+/, '\1')
              polygons << p2
            end
          
            Precinct.where(id: p.id).update_all([ DataLoader::GEO_QUERY, DataLoader::MULTI % polygons.join ])
          end
        end
      end

      precinct_splits.each do |split, matched_gpus|
        p_split = locality.precincts.find_by_uid(split)
        matched_gpus[:precincts].each do |p|
          p_split.precinct = p unless p_split == p          
        end
        matched_gpus[:districts].each do |d|
          matched_gpus[:precincts].each do |p|
            d.precincts << p
          end
          d.save!
        end
        p_split.save! if p_split
      end
      
      if er.party_collection
        er.party_collection.party.each_with_index do |p,i|
          name = p.name
          name = p.abbreviation if name.blank?
          existing_party = Party.where(uid: p.object_id, locality_id: locality.id)
          if !existing_party.any?
            locality.parties << Party.new(uid: p.object_id, name: name, sort_order: i, abbr: p.abbreviation)
          end
        end
      end

      offices = {}
      if er.office_collection
        if er.office_collection
          er.office_collection.office.each do |o|
            offices[o.object_id] = o
          end
        end
      end
      mismatches = {}

      locality.save!
      
      
      if er.election && er.election.first
        er.election.first.tap do |e|
          candidates = {}
          e.candidate_collection.candidate.each do |c|
            candidates[c.object_id] = c
          end
        
          # where is this in hart??
          #   election.election_type = e.type
          e.contest_collection.contest.each do |c|
            if c.is_a?(VSSC::CandidateChoice)
              contest = Contest.new(uid: c.object_id, election: election,
                office: offices[c.office] ? offices[c.office].name : c.name,
                sort_order: c.sequence_order)              
              
              contest.district = District.where(locality_id: locality.id, uid: c.contest_gp_scope).first
              if contest.district.nil? 
                raise c.contest_gp_scope.to_s
                mismatches[:districts] ||= []
                mismatches[:districts] << c.contest_gp_scope
              end
            
              precinct_results = {}
            
              c.ballot_selection.each_with_index do |candidate_sel, i|
                next if candidate_sel.is_write_in #TODO: don't know write-in party_ids
                  
                sel = candidates[candidate_sel.candidate.first] #TODO: can be multiple candidates in VSSC
                next if sel.party.blank?
                party = Party.where(uid: sel.party, locality_id: locality.id).first
                if party.nil? && !candidate_sel.is_write_in
                  raise sel.inspect.to_s + ' ' + locality.parties.collect(&:uid).to_s
                end
                color = party ? ColorScheme.candidate_pre_color(party.name) : nil
                candidate = Candidate.new(uid: sel.object_id, 
                  name: sel.ballot_name, 
                  sort_order: sel.sequence_order, 
                  party_id: party ? party.id : nil, 
                  color: color)
              
                contest.candidates << candidate
              
                candidate_sel.vote_counts.each do |vc|
                  d_uid = fix_district_uid(vc.gp_unit)
                  raise precinct_splits[d_uid][:precincts].inspect.to_s if precinct_splits[d_uid][:precincts].count > 1
                  precinct = precinct_splits[d_uid][:precincts].first || Precinct.find_by_uid("#{d_uid}")

                  if precinct
                    precinct_results[d_uid] ||= ContestResult.new(:uid=>"result-#{contest.uid}-#{precinct.uid}", :certification=>"unofficial_partial", precinct_id: precinct.id)
                  else
                    precinct_results[d_uid] ||=   ContestResult.new(:uid=>"result-#{contest.uid}-#{d_uid}", :certification=>"unofficial_partial")
                  end
                
                  cr = precinct_results[d_uid]
                
                  if precinct
                    cr.candidate_results << CandidateResult.new(candidate: candidate, precinct_id: precinct.id,
                      votes: vc.count, uid: "#{contest.uid}-#{precinct.uid}-#{candidate.uid}")
                  else
                    mismatches[:precincts] ||= []
                    mismatches[:precincts] << d_uid
                    cr.candidate_results << CandidateResult.new(candidate: candidate,
                      votes: vc.count, uid: "#{contest.uid}-#{d_uid}-#{candidate.uid}")
                  end
                  precinct_results[d_uid] ||= cr
                
                end
              
              end
              contest.contest_results = precinct_results.values
            
              locality.contests << contest
            elsif c.is_a?(VSSC::BallotMeasure)
              ref = Referendum.new(uid: c.object_id, 
                sort_order: c.sequence_order,
                title: c.name,
                subtitle: c.summary_text,
                question: c.full_text)
              
              ref.district = District.where(locality_id: locality.id, uid: c.contest_gp_scope).first
              if ref.district.nil? 
                raise c.contest_gp_scope.to_s
                mismatches[:districts] ||= []
                mismatches[:districts] << c.contest_gp_scope
              end
            
              precinct_results = {}
            
              c.ballot_selection.each_with_index do |sel, i|
                
                response = BallotResponse.new(uid: sel.object_id, 
                  name: sel.selection)
              
                ref.ballot_responses << response
                
                
                sel.vote_counts.each do |vc|
                  d_uid = fix_district_uid(vc.gp_unit)
                  raise precinct_splits[d_uid][:precincts].inspect.to_s if precinct_splits[d_uid][:precincts].count > 1
                  precinct = precinct_splits[d_uid][:precincts].first || Precinct.find_by_uid("#{d_uid}")

                  if precinct
                    precinct_results[d_uid] ||= ContestResult.new(:uid=>"result-#{ref.uid}-#{precinct.uid}", :certification=>"unofficial_partial", precinct_id: precinct.id)
                  else
                    precinct_results[d_uid] ||= ContestResult.new(:uid=>"result-#{ref.uid}-#{d_uid}", :certification=>"unofficial_partial")
                  end
                
                  cr = precinct_results[d_uid]
                
                  if precinct
                    cr.ballot_response_results << BallotResponseResult.new(ballot_response: response, precinct_id: precinct.id,
                      votes: vc.count, uid: "#{ref.uid}-#{precinct.uid}-#{response.uid}")
                  else
                    mismatches[:precincts] ||= []
                    mismatches[:precincts] << d_uid
                    cr.ballot_response_results << BallotResponseResult.new(ballot_response: candidate,
                      votes: vc.count, uid: "#{ref.uid}-#{d_uid}-#{response.uid}")
                  end
                  precinct_results[d_uid] ||= cr
                
                end
              
              end
              ref.contest_results = precinct_results.values
            
              locality.referendums << ref
            elsif c.is_a?(VSSC::StraightParty)
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
      
      
      
      election.save!
      
      return mismatches
    end
    
  end
  
  
end