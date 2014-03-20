json.results @results do |json, r|
  if r[:contest_id]
    json.contest_id r[:contest_id]
    json.results r[:results] do |json, cv|
      json.candidate_id  cv[:candidate_id]
      json.votes         cv[:votes]
    end
  else
    json.referendum_id r[:referendum_id]
    json.results r[:results] do |json, bv|
      json.ballot_response_id  bv[:ballot_response_id]
      json.votes               bv[:votes]
    end
  end
end
