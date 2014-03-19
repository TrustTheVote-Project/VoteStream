json.referenda @referendums do |json, r|
  json.id         r.uid
  json.title      r.title
  json.subtitle   r.subtitle
  json.question   r.question
  json.sort_order r.sort_order

  json.ballot_responses r.ballot_responses do |json, br|
    json.id         br.uid
    json.name       br.name
    json.sort_order br.sort_order
  end
end
