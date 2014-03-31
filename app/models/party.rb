class Party < ActiveRecord::Base

  validates :name, presence: true
  validates :abbr, presence: true
  validates :uid, uniqueness: { scope: [ :locality_id ] }

  def self.create_undefined(locality, uid)
    locality.parties.create(name: "Undefined-#{uid}", sort_order: 9999, abbr: 'UNDEF', uid: uid)
  end
  
end
