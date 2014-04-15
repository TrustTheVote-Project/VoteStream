json.localities @localities do |json, l|
  json.id l.uid
  json.name l.name
  json.type l.locality_type

  json.precincts l.precincts do |json, p|
    json.id p.uid
    json.name p.name
    json.electoral_district_ids p.districts.pluck(:uid)
  end
end
