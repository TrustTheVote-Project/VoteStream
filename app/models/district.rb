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

end
