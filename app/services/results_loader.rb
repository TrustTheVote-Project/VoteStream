class ResultsLoader < BaseLoader

  CANDIDATE_RESULTS_COLUMNS       = [ :contest_result_id, :uid, :precinct_id, :candidate_id, :votes ]
  BALLOT_RESPONSE_RESULTS_COLUMNS = [ :contest_result_id, :uid, :precinct_id, :ballot_response_id, :votes ]
  CONTEST_RESULTS_COLUMNS         = [ :uid, :certification, :precinct_id, :contest_id, :referendum_id, :total_votes, :total_valid_votes, :color_code ]

  STATE = 'state'
  CONTEST_RESULT = 'contest_result'
  JURISDICTION_ID = 'jurisdiction_id'
  CONTEST_ID = 'contest_id'
  REFERENDUM_ID = 'referendum_id'
  TOTAL_VOTES = 'total_votes'
  TOTAL_VALID_VOTES = 'total_valid_votes'
  BALLOT_LINE_RESULT = 'ballot_line_result'
  CANDIDATE_ID = 'candidate_id'
  BALLOT_RESPONSE_ID = 'ballot_response_id'
  VOTES = 'votes'

  NO_VOTES_COLOR = 'n0'

  NONPARTISAN = 'nonpartisan'
  REPUBLICAN = 'republican'
  DEMOCRATIC_1 = 'democratic-farmer-labor'
  DEMOCRATIC_2 = 'democratic'
  YES = 'yes'
  NO = 'no'

  attr_accessor :purge_results
  attr_accessor :state, :locality
  attr_accessor :contest_results, :candidate_results, :ballot_response_results, :contest_counter
  attr_accessor :contest_ids, :candidate_ids, :candidate_parties
  attr_accessor :referendum_ids, :ballot_response_ids, :ballot_response_names
  attr_accessor :precinct_ids, :precinct_total

  def initialize(xml_source, options = {})
    @options = {}
    @xml_source = xml_source
    @threshold_lower = AppConfig['map_color']['threshold']['lower']
    @threshold_upper = AppConfig['map_color']['threshold']['upper']
  end

  def load
    loader = self
    @purge_results = !@options[:keep_results]

    @contest_results = []
    @contest_counter = 0
    @candidate_results = []
    @ballot_response_results = []

    Precinct.transaction do
      Xml::Parser.new(Nokogiri::XML::Reader(@xml_source)) do
        loader.parse_state(self)
        loader.parse_contest_result(self)
      end

      flush_results

      # Save precinct_total
      self.precinct_total.each do |precinct_id, total_cast|
        Precinct.where(id: precinct_id).update_all(total_cast: total_cast)
      end

      DataProcessor.on_results_upload
    end
  end

  def parse_state(reader)
    loader = self
    reader.for_element STATE do
      loader.state = State.find_by!(uid: attribute('id'))

      inside_element do
        for_element 'locality' do
          loader.locality = Locality.find_by!(uid: attribute('id'))
        end
      end
    end
  end


  def parse_contest_result(reader)
    loader = self
    reader.for_element CONTEST_RESULT do
      # purge results if necessary
      if loader.purge_results
        loader.purge_results = false
        loader.purge_locality_results(loader.locality)
      end

      unless loader.contest_ids
        loader.contest_ids    = loader.locality.contests.select('id, uid').inject({}) { |m, c| m[c.uid] = c.id; m }
        loader.referendum_ids = loader.locality.referendums.select('id, uid').inject({}) { |m, r| m[r.uid] = r.id; m }
        loader.precinct_ids   = loader.locality.precincts.select('id, uid').inject({}) { |m, p| m[p.uid] = p.id; m }

        contest_ids = loader.locality.contest_ids
        loader.candidate_ids  = Candidate.select('id, uid').where(contest_id: contest_ids).inject({}) { |m, c| m[c.uid] = c.id; m }
        loader.candidate_parties = Candidate.select('candidates.id, candidates.sort_order, LOWER(parties.name) pname').joins(:party).where(contest_id: contest_ids).inject({}) { |m, c| m[c.id] = [ c.pname, c.sort_order ]; m }

        referendum_ids = loader.locality.referendum_ids
        loader.ballot_response_ids = BallotResponse.select('id, uid').where(referendum_id: referendum_ids).inject({}) { |m, c| m[c.uid] = c.id; m }
        loader.ballot_response_names = BallotResponse.select('id, sort_order, LOWER(name) pname').where(referendum_id: referendum_ids).inject({}) { |m, c| m[c.id] = [ c.pname, c.sort_order ]; m }

        loader.precinct_total = {}
      end

      contest_result = ContestResult.new(uid: attribute('id'), certification: attribute('certification'))

      items = []
      inside_element do
        for_element(JURISDICTION_ID)   { contest_result.precinct_id = loader.precinct_ids[loader.dequote(inner_xml)] }
        for_element(CONTEST_ID)        { contest_result.contest_id = loader.contest_ids[loader.dequote(inner_xml)] }
        for_element(REFERENDUM_ID)     { contest_result.referendum_id = loader.referendum_ids[loader.dequote(inner_xml)] }
        for_element(TOTAL_VOTES)       { contest_result.total_votes = inner_xml }
        for_element(TOTAL_VALID_VOTES) { contest_result.total_valid_votes = inner_xml }

        for_element BALLOT_LINE_RESULT do
          blr_uid = attribute('id')
          item_id = nil
          votes   = 0

          inside_element do
            for_element(CANDIDATE_ID)  { item_id = loader.candidate_ids[loader.dequote(inner_xml)] }
            for_element(BALLOT_RESPONSE_ID) { item_id = loader.ballot_response_ids[loader.dequote(inner_xml)] }
            for_element(VOTES)         { votes = inner_xml }
          end

          items << [ contest_result.uid, blr_uid, contest_result.precinct_id, item_id, votes.to_i ]
        end
      end

      items.sort_by! { |i| -i[4] }
      total_votes = contest_result.total_votes
      diff = (items[0][4] - (items[1].try(:[], 4) || 0)) * 100 / (total_votes == 0 ? 1 : total_votes)
      leader_id = items[0][3]

      if contest_result.contest_related?
        contest_result.color_code = loader.candidate_color_code(leader_id, diff, total_votes)
        loader.candidate_results.push(*items)
      else
        contest_result.color_code = loader.ballot_response_color_code(leader_id, diff, total_votes)
        loader.ballot_response_results.push(*items)
      end

      loader.contest_results << contest_result

      # if we have enough data, flush it and start counting
      loader.contest_counter += 1
      loader.flush_results if loader.contest_counter % 1000 == 0

      loader.precinct_total[contest_result.precinct_id] = contest_result.total_votes
    end
  end

  def flush_results
    ContestResult.import @contest_results
    contest_result_ids = ContestResult.select('id, uid').where(uid: @contest_results.map(&:uid)).inject({}) { |m, r| m[r.uid] = r.id; m }
    @contest_results.clear

    @candidate_results.each { |r| r[0] = contest_result_ids[r[0]] }
    CandidateResult.import CANDIDATE_RESULTS_COLUMNS, @candidate_results
    @candidate_results.clear

    @ballot_response_results.each { |r| r[0] = contest_result_ids[r[0]] }
    BallotResponseResult.import BALLOT_RESPONSE_RESULTS_COLUMNS, @ballot_response_results
    @ballot_response_results.clear

    puts "#{@contest_counter}: #{ObjectSpace.count_objects.inspect}"
  end

  def candidate_color_code(candidate_id, diff, total_votes)
    if total_votes == 0
      return NO_VOTES_COLOR
    else
      party, sort_order = @candidate_parties[candidate_id]
      if party == NONPARTISAN
        c = sort_order == 1 ? '1' : '2'
      elsif party == REPUBLICAN
        c = 'r'
      elsif party == DEMOCRATIC_1 or party == DEMOCRATIC_2
        c = 'd'
      else
        c = 'o'
      end

      return "#{c}#{shade(diff)}"
    end
  end

  def ballot_response_color_code(ballot_response_id, diff, total_votes)
    if total_votes == 0
      return NO_VOTES_COLOR
    else
      name, sort_order = @ballot_response_names[ballot_response_id]
      if name == YES
        c = 'Y'
      elsif name == NO
        c = 'N'
      else
        c = sort_order == 1 ? 'Y' : 'N'
      end

      return "#{c}#{shade(diff)}"
    end
  end

  def shade(diff)
    if diff < @threshold_lower
      2
    elsif diff < @threshold_upper
      1
    else
      0
    end
  end

end
