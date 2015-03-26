require 'vssc'
class VSSCLoader < BaseLoader
  
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
  
  def load(locality_id)
    er = ::VSSC::Parser.parse(@xml_source)
    Election.transaction do
      election = Election.new(uid: er.object_id + '-vssc')
      Election.where(uid: election.uid).destroy_all
      
      election.held_on = er.date
      election.state = State.find_by(code: er.state_abbreviation)

      # election.statewide = false # what does this mean ??

      
      election.election_type = "general"
      
      locality = Locality.find(locality_id)

      
      # first load up all the districts
      precinct_splits = {}
      er.gp_unit_collection.gp_unit.each do |gp_unit|
        if gp_unit.is_a?(VSSC::District)
          d_uid = fix_district_uid(gp_unit.object_id)
          # TODO: This is a temp "guesser" for the ID format to match existing ones
          d = District.find_by_uid(d_uid)
          if d.nil?
            # type = case gp_unit.district_type
            # when VSSC::DistrictType.congressional, VSSC::DistrictType.statewide
            #   "Federal"
            # when VSSC::DistrictType.state_house, VSSC::DistrictType.state_senate
            #   "State"
            # when VSSC::DistrictType.locality
            #   "MCD"
            # else
            #   "Other"
            # end
            # d = District.new(name: gp_unit.name, district_type: type, uid: gp_unit.object_id)
            # d.save!
            # locality.districts << d
          end
          if d
            precinct_splits[d.uid] ||= {:districts=>[], :precincts=>[]}
            precinct_splits[d.uid][:districts] << d
            gp_unit.gp_sub_unit_ref.each do |sub_gp_id|
              sub_gp_id = fix_district_uid(sub_gp_id)
              precinct_splits[sub_gp_id] ||= {:districts=>[], :precincts=>[]}
              precinct_splits[sub_gp_id][:districts] << d
            end
          end
        else
          p_uid = fix_district_uid(gp_unit.object_id)
          p = Precinct.find_by_uid(p_uid)
          if p.nil?
            # p = Precinct.new(uid: gp_unit.object_id, name: gp_unit.object_id)
            # locality.precincts << p
          end
          if p
            precinct_splits[p.uid] ||= {:districts=>[], :precincts=>[]}
            precinct_splits[p.uid][:precincts] << p
            gp_unit.gp_sub_unit_ref.each do |sub_gp_id|
              sub_gp_id = fix_district_uid(sub_gp_id)
              precinct_splits[sub_gp_id] ||= {:districts=>[], :precincts=>[]}
              precinct_splits[sub_gp_id][:precincts] << p
            end
          end
        end
      end

      precinct_splits.each do |split, matched_gpus|
        matched_gpus[:districts].each do |d|
          puts d.name, matched_gpus[:precincts].count
          matched_gpus[:precincts].each do |p|
            d.precincts << p
          end
        end
      end

      er.party_collection.party.each_with_index do |p,i|
        name = p.name
        name = p.abbreviation if name.blank?
        existing_party = Party.where(uid: p.object_id, locality_id: locality.id)
        if !existing_party.any?
          locality.parties << Party.new(uid: p.object_id, name: name, sort_order: i, abbr: p.abbreviation)
        end
      end

      offices = {}
      if er.office_collection
        er.office_collection.office.each do |o|
          offices[o.object_id] = o
        end
      end
      
      mismatches = {}

      locality.save!
      
      
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
            d_uid = fix_district_uid(c.contest_gp_scope)
            contest.district = District.where(locality_id: locality.id, uid: d_uid).first
            if contest.district.nil? 
              mismatches[:districts] ||= []
              mismatches[:districts] << c.contest_gp_scope
            end
            
            precinct_results = {}
            
            c.ballot_selection.each_with_index do |candidate_sel, i|
              sel = candidates[candidate_sel.candidate.first] #TODO: can be multiple candidates in VSSC
              party = Party.where(uid: sel.party, locality_id: locality.id).first
              # if party.nil?
              #   raise sel.party.to_s + ' ' + locality.parties.collect(&:uid).to_s
              # end
              color = ColorScheme.candidate_pre_color(party.name)
              candidate = Candidate.new(uid: sel.object_id, 
                name: sel.ballot_name, 
                sort_order: sel.sequence_order, 
                party_id: party.id, 
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
      
      locality.save!
      
      
      
      election.save!
      
      
      return mismatches
    end
    
  end
  
  
end