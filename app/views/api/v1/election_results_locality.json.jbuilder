json.locality do
  json.id   @locality.uid
  json.name @locality.name

  json.precincts @results do |json, pr|
    json.id   pr[:puid]
    json.name pr[:pname]

    json.contest_results pr[:r] do |json, cr|
      json.id                cr[:couid]
      json.certification     cr[:cert]

      if cuid = cr[:cuid]
        json.contest_id      cuid
        json.contest_name    cr[:cname]
      else
        json.referendum_id   cr[:ruid]
        json.referendum_name cr[:rname]
      end

      json.total_votes       cr[:tv]
      json.total_valid_votes cr[:tvv]
      json.overvotes         0
      json.blank_votes       0

      json.ballot_line_results cr[:r] do |json, cv|
        json.id              cv[:id]
        json.candidate_id    cv[:cauid] if cv[:cauid]
        json.candidate_name  cv[:caname] if cv[:caname]
        json.response_id     cv[:bruid] if cv[:bruid]
        json.response_name   cv[:brname] if cv[:brname]
        json.votes           cv[:v]
      end
    end
  end
end
