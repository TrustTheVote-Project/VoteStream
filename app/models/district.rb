class District < ActiveRecord::Base

  FEDERAL = 'Federal'

  # a hack to isolate districts from other localities
  # federal and state districts should really be shared, but since contests / referendums
  # aren't we get ugly cross-locality results. That's why we split districts on every level for now.
  belongs_to :locality

  has_and_belongs_to_many :precincts

  has_many :contests
  has_many :referendums

  validates :uid, presence: true
  validates :name, presence: true
  validates :district_type, presence: true

  def nist_district_type
    t = Vedaspace::Enum::ReportingUnitType.find(self.district_type) 
    
    # TODO: Actually save NIST district type along with "district type" and simply return that
    
    t = t || case self.district_type
    when "School District"
      Vedaspace::Enum::ReportingUnitType.school
    when "Aquifer District", "WCID", "Water District"
      Vedaspace::Enum::ReportingUnitType.water
    when "Municipal Utility District", "MUD"
      Vedaspace::Enum::ReportingUnitType.utility
    when "Community College", "Library District"
      Vedaspace::Enum::ReportingUnitType.other
    when "State House"
      Vedaspace::Enum::ReportingUnitType.state_house
    when "State Senate"
      Vedaspace::Enum::ReportingUnitType.state_senate
    when "Federal", "Federal Ballot", "All", "Statewide"
      Vedaspace::Enum::ReportingUnitType.state
    else
      Vedaspace::Enum::ReportingUnitType.other
    end
    
    return t
  end

end
