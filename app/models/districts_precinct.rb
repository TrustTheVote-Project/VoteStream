class DistrictsPrecinct < ActiveRecord::Base
  belongs_to :district
  belongs_to :precinct
end
