json.contests @contests do |json, c|
  json.id         c.uid
  json.electoral_district_id c.district.uid
  json.office     c.office
  json.partisan   c.partisan? ? 'yes' : 'no'
  json.write_in   c.write_in? ? 'yes' : 'no'
  json.sort_order c.sort_order

  json.candidates c.candidates do |json, ca|
    json.id         ca.uid
    json.name       ca.name
    json.party      ca.party.name
    json.sort_order ca.sort_order
  end
end
