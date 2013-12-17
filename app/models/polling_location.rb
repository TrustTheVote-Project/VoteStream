class PollingLocation < ActiveRecord::Base

  belongs_to :precinct
  belongs_to :address

  validates :name, presence: true

end
