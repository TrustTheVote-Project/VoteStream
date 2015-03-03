require 'vssc'
class VSSCLoader < BaseLoader
  
  def initialize(xml_source)
    @xml_source = xml_source
  end
  
  def load
    er = ::VSSC::Parser.parse(@xml_source)
    Election.transaction do
      election = Election.new(uid: er.object_id + '-vssc')
      election.held_on = er.date
      election.state = State.find_by(code: er.state_abbreviation)

      # election.statewide = false # what does this mean ??

      
      election.election_type = "general"
      
      
      locality = Locality.new(name: "Travis County - VSSC", 
                      locality_type: "County", 
                      state: election.state, 
                      uid: "tvcounty-vssc-test")
      
      Locality.where(uid: locality.uid).delete_all
      
      # first load up all the districts
      #districts = []
      #precincts = []
      precinct_splits = {}                                
      er.gp_unit_collection.gp_unit.each do |gp_unit|
        if gp_unit.is_a?(VSSC::District)
          type = gp_unit.district_type
          type = "Other"
          d = District.new(name: gp_unit.name, district_type: type, uid: gp_unit.object_id)
          d.save!
          locality.districts << d
          gp_unit.gp_sub_unit_ref.each do |sub_gp_id|
            precinct_splits[sub_gp_id] ||= {:districts=>[], :precincts=>[]}
            precinct_splits[sub_gp_id][:districts] << d
          end
        else
          p = Precinct.new(uid: gp_unit.object_id, name: gp_unit.object_id)
          locality.precincts << p
          gp_unit.gp_sub_unit_ref.each do |sub_gp_id|
            precinct_splits[sub_gp_id] ||= {:districts=>[], :precincts=>[]}
            precinct_splits[sub_gp_id][:precincts] << p
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
      

      er.election.first.tap do |e|
        # where is this in hart??
        #   election.election_type = e.type        
      end
      
      locality.save!
      
      Election.where(uid: election.uid).delete_all
      election.save!
      
    end
    
  end
  
  
end