json.precincts [ @precinct ] do
  json.id   @precinct.uid
  json.name @precinct.name

  json.contest_results @results do |json, r|
    json.id                r[:id]
    json.certification     r[:certification]
    json.contest_id        r[:contest_id]
    json.contest_name      r[:contest_name]
    json.total_votes       r[:total_votes]
    json.total_valid_votes r[:total_valid_votes]
    json.overvotes         r[:overvotes]
    json.blank_votes       r[:blank_votes]

    json.ballot_line_results r[:ballot_line_results] do |json, cv|
      json.id             cv[:id]
      json.candidate_id   cv[:candidate_id] if cv[:candidate_id]
      json.candidate_name cv[:candidate_name] if cv[:candidate_name]
      json.response_id    cv[:response_id] if cv[:response_id]
      json.response_name  cv[:response_name] if cv[:response_name]
      json.votes          cv[:votes]
    end
  end
end
