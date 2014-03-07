json.elections @elections do |json, e|
  json.id            e.uid
  json.date          e.held_on
  json.election_type e.election_type
  json.state_id      e.state.uid
  json.statewide     e.statewide ? "yes" : "no"
end
