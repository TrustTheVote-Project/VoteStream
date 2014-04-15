json.locality do
  json.id   @locality.uid
  json.name @locality.name

  json.precincts @results do |json, pr|
    json.id   pr[:puid]
    json.name pr[:pname]

    json.contest_results pr[:r] do |json, cr|
      json.id cr[:couid]

      if cuid = cr[:cuid]
        json.contest_id cuid
      else
        json.referendum_id cr[:ruid]
      end

      json.ballot_line_results cr[:r] do |json, cv|
        json.id             cv[:id]
        json.candidate_id   cv[:cauid] if cv[:cauid]
        json.candidate_name cv[:caname] if cv[:caname]
        json.response_id    cv[:bruid] if cv[:bruid]
        json.response_name  cv[:brname] if cv[:brname]
        json.votes          cv[:v]
      end
    end
  end
end
