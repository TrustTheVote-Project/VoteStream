class Precinct < ActiveRecord::Base

  belongs_to :locality

  belongs_to :precinct #Linking between precinct for unifying/mapping
  
  has_and_belongs_to_many :districts
  

  has_one    :polling_location,        dependent: :delete
  has_many   :candidate_results,       dependent: :delete_all
  has_many   :ballot_response_results, dependent: :delete_all
  has_many   :contest_results,         dependent: :delete_all
  has_many   :districts_precincts

  validates :uid, presence: true
  validates :name, presence: true

  def contests
    self.locality.contests.where(district_id: self.district_ids)
  end

  def referendums
    self.locality.referendums.where(district_id: self.district_ids)
  end
  
  def geo
    self.read_attribute(:geo) || (self.precinct ? self.precinct.geo : nil)
  end

end
