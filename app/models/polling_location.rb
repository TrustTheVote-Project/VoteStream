class PollingLocation < ActiveRecord::Base

  belongs_to :precinct

  validates :name, presence: true

end
