class DemographicsLoader < BaseLoader

  def initialize(csv_source)
    @csv_source = csv_source
  end


  def load(locality_id)
    @locality = Locality.find(locality_id)
    build_voter_regs
    
    save_voter_regs
    
  end
  
  def build_voter_regs
    @voter_registrations = []
    @voter_registration_classifications = {}
    # TODO: ocd_id vs uid vs object_id ? 
    @precinct_hash = @locality.precincts.inject({}) {|h,p| h[p.uid] = p.id; h }
    
    CSV.parse(@csv_source.read, headers: true) do |r|
      v = VoterRegistration.new
      v.date_of_birth = r["DateofBirth"]
      v.phone = r["Phone"]
      v.race = r["Race"]
      v.sex = r["Sex"]
      v.party = r["Party"]
      v.voter_id_type = r["VoterIDtype"]
      v.voter_id_value = r["VoterIDvalue"]
      v.registration_address = r["RegistrationAddress"]
      
      v.precinct_id = @precinct_hash[r["Precinct"]]
      
      @voter_registrations << v
      @voter_registration_classifications["#{v.voter_id_type}-#{v.voter_id_value}"] ||= []
      r["VoterClassifications"].to_s.split(',').each do |cname|
        @voter_registration_classifications["#{v.voter_id_type}-#{v.voter_id_value}"] << VoterRegistrationClassification.new(name: cname)
      end
    end
  end
  
  def save_voter_regs
    grp_size = 5000
    @voter_registrations.in_groups_of(grp_size, false) do |group|    
      VoterRegistration.import(group)
    end
    
    # Rebuild VR list in memory
    @voter_registration_ids = {}
    VoterRegistration.where(precinct_id: @precinct_hash.values).each do |vr|
      @voter_registration_ids["#{vr.voter_id_type}-#{vr.voter_id_value}"] = vr.id      
    end
    
    # Set the classification ids:
    @voter_registration_classifications.each do |k,vrc_list|
      vrc_list.each do |vrc|
        vrc.voter_registration_id = @voter_registration_ids[k]
      end
    end
    
    # Save the classifications
    @voter_registration_classifications.values.flatten.in_groups_of(grp_size, false) do |group|    
      VoterRegistrationClassification.import(group)
    end
    
  end

end