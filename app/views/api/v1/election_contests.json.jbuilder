json.contests @contests do |json, c|
  json.id         c.uid
  json.electoral_district_id c.district.uid
  json.office     c.office
  json.partisan   nil
  json.write_in   nil
  json.sort_order c.sort_order

  json.candidates c.candidates do |json, ca|
    json.id         ca.uid
    json.name       ca.name
    json.party      ca.party.name
    json.sort_order ca.sort_order
  end
end
