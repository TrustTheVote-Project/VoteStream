class DemographicsLoader < BaseLoader

  def initialize(csv_source)
    @csv_source = csv_source
    @grp_size = 1000
  end

  attr_reader :grp_size

  def load(locality_id)
    @locality = Locality.find(locality_id)
    
    puts "Build Reg List"
    build_voter_regs
    
  end
  
  def build_voter_regs
    @voter_registrations = []
    @voter_registration_classifications = {}
    # TODO: ocd_id vs uid vs object_id ? 
    @precinct_hash = @locality.precincts.inject({}) {|h,p| h[p.uid] = p.id; h }
    puts "Read file" 
    rows = CSV.parse(@csv_source.read, headers: true)
    total = rows.size
    puts "Read #{total} rows"
    rows.each_with_index do |r, i|
      if (i % (grp_size * 2)==0)
        puts "Read row #{i} of #{total}"
        save_voter_regs
        @voter_registrations = []
        @voter_registration_classifications = {}
      end
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

      v.uid = SecureRandom.uuid
      
      @voter_registrations << v
      @voter_registration_classifications[v.uid] ||= []
      r["VoterClassifications"].to_s.split(',').each do |cname|
        @voter_registration_classifications[v.uid] << VoterRegistrationClassification.new(name: cname)
      end
    end
    
    save_voter_regs
  end
  
  def save_voter_regs
    i = 0
    total = @voter_registrations.size
    @voter_registrations.in_groups_of(grp_size, false) do |group|    
      puts "Importing VR #{i * grp_size} - #{(i+1)*grp_size} of #{total}"
      VoterRegistration.import(group)
      i+=1
    end
    
    # Rebuild VR list in memory
    puts "Rebuild VR ID/UID List"
    @voter_registration_ids = {}
    VoterRegistration.where(uid: @voter_registration_classifications.keys).select("id, uid").each do |vr|
      @voter_registration_ids[vr.uid] = vr.id      
    end
    
    # Set the classification ids:
    puts "Associate Classifications with VRs"
    @voter_registration_classifications.each do |k,vrc_list|
      vrc_list.each do |vrc|
        vrc.voter_registration_id = @voter_registration_ids[k]
      end
    end
    
    # Save the classifications
    i=0
    total = @voter_registration_classifications.values.flatten.size
    @voter_registration_classifications.values.flatten.in_groups_of(grp_size, false) do |group|    
      puts "Importing VR Classification #{i * grp_size} - #{(i+1)*grp_size} of #{total}"
      VoterRegistrationClassification.import(group)
      i+=1
    end
    
  end

end