json.districts @districts do |json, d|
  json.id   d.uid
  json.name d.name
  json.type d.district_type
end
