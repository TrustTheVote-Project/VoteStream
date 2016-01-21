class Party < ActiveRecord::Base

  belongs_to :locality

  validates :name, presence: true
  validates :abbr, presence: true
  validates :uid, uniqueness: { scope: [ :locality_id ] }

  def self.create_undefined(locality, uid)
    locality.parties.create(name: "Undefined-#{uid}", sort_order: 9999, abbr: 'UNDEF', uid: uid)
  end
  
  
  def self.no_party(locality)
    locality.parties.where(abbr: "NP").first || locality.parties.create(
      name: "No Party",
      sort_order: 9999,
      abbr: "NP",
      uid: locality.uid.to_s + "-no-party"
    )
  end
  
end
