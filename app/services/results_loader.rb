class ResultsLoader < BaseLoader

  CANDIDATE_RESULTS_COLUMNS       = [ :contest_result_id, :uid, :precinct_id, :candidate_id, :votes ]
  BALLOT_RESPONSE_RESULTS_COLUMNS = [ :contest_result_id, :uid, :precinct_id, :ballot_response_id, :votes ]
  CONTEST_RESULTS_COLUMNS         = [ :uid, :certification, :precinct_id, :contest_id, :referendum_id, :total_votes, :total_valid_votes ]

  def initialize(xml_source, options = {})
    @options = {}
    @xml_source = xml_source
    @doc = Nokogiri::XML(xml_source)
    @doc.remove_namespaces!
  end

  def load
    @districts = {}
    @precinct_ids = {}
    @candidate_ids = {}
    @ballot_response_ids = {}

    @locality = find_locality(@doc)

    Precinct.transaction do
      remove_old_results unless @options[:keep_old_results]
      load_new_results

      DataProcessor.on_results_upload
    end
  end

  private

  def find_locality(doc)
    locality_uid = doc.css('state > locality').first.try(:[], 'id')
    if locality_uid.blank?
      contest_uid = dequote(doc.css('contest_result > contest_id').first.content)
      return Contest.find_by!(uid: contest_uid).locality
    else
      return Locality.find_by!(uid: locality_uid)
    end
  end

  def remove_old_results
    contest_ids = @locality.contest_ids
    ContestResult.where(contest_id: contest_ids).destroy_all
  end

  def load_new_results
    contest_uids    = @doc.css('contest_result > contest_id').map { |el| dequote(el.content) }
    contest_ids     = Contest.where(uid: contest_uids).select('uid, id').inject({}) { |m, r| m[r.uid] = r.id; m }
    referendum_uids = @doc.css('contest_result > referendum_id').map { |el| dequote(el.content) }
    referendum_ids  = Referendum.where(uid: referendum_uids).select('uid, id').inject({}) { |m, r| m[r.uid] = r.id; m }

    results = []

    @doc.css('contest_result').each do |cr_el|
      precinct_uid = dequote(cr_el.css('> jurisdiction_id').first.content)
      precinct_id = @precinct_ids[precinct_uid]
      total_votes = cr_el.css('> total_votes').first.content

      unless precinct_id
        precinct = Precinct.find_by!(uid: precinct_uid)
        precinct_id = @precinct_ids[precinct_uid] = precinct.id
        precinct.total_cast = total_votes
        precinct.save
      end

      if contest_uid = dequote(cr_el.css('> contest_id').first.try(:content))
        contest_id = contest_ids[contest_uid] or raise "Contest with UID #{contest_uid} wasn't found"
      elsif referendum_uid = dequote(cr_el.css('> referendum_id').first.try(:content))
        referendum_id = referendum_ids[referendum_uid] or raise "Referendum with UID #{referendum_uid} wasn't found"
      end

      results << [
        cr_el['id'],
        cr_el['certification'],
        precinct_id,
        contest_id,
        referendum_id,
        total_votes,
        cr_el.css('> total_valid_votes').first.content
      ]
    end
    ContestResult.import CONTEST_RESULTS_COLUMNS, results

    @contest_result_ids = ContestResult.select('id, uid').inject({}) { |m, r| m[r.uid] = r.id; m }
    load_contest_and_referendum_results
  end

  def load_contest_and_referendum_results
    candidate_results = []
    ballot_response_results = []

    uids = @doc.css('contest_result candidate_id').map { |el| dequote(el.content) }
    @candidate_ids = Candidate.select('id, uid').where(uid: uids).inject({}) { |m, r| m[r.uid] = r.id; m }
    uids = @doc.css('contest_result ballot_response_id').map { |el| dequote(el.content) }
    @ballot_response_ids = BallotResponse.select('id, uid').where(uid: uids).inject({}) { |m, r| m[r.uid] = r.id; m }

    @doc.css('contest_result').each do |cr_el|
      cr_id = @contest_result_ids[cr_el['id']]

      cr_el.css('ballot_line_result').each do |blr_el|
        uid = blr_el['id']
        votes = blr_el.css('votes').first.content
        precinct_uid = dequote(blr_el.css('> jurisdiction_id').first.content)
        precinct_id = @precinct_ids[precinct_uid]

        if el = blr_el.css('> candidate_id').first
          candidate_uid = dequote(el.content)
          candidate_id = @candidate_ids[candidate_uid]

          candidate_results << [ cr_id, uid, precinct_id, candidate_id, votes ]
        elsif el = blr_el.css('> ballot_response_id').first
          ballot_response_uid = dequote(el.content)
          ballot_response_id = @ballot_response_ids[ballot_response_uid]

          ballot_response_results << [ cr_id, uid, precinct_id, ballot_response_id, votes ]
        end
      end
    end

    CandidateResult.import(CANDIDATE_RESULTS_COLUMNS, candidate_results) unless candidate_results.blank?
    BallotResponseResult.import(BALLOT_RESPONSE_RESULTS_COLUMNS, ballot_response_results) unless ballot_response_results.blank?
  end

  def load_referendum_results(cr_el, cr)
    results = []

    cr_el.css('ballot_line_result').each do |blr_el|
      ballot_response_uid = dequote(blr_el.css('> ballot_response_id').first.content)
      ballot_response_id = @ballot_response_ids[ballot_response_uid] || (@ballot_response_ids[ballot_response_uid] = BallotResponse.find_by!(uid: ballot_response_uid).id)

      results << [
        blr_el['id'],
        cr.precinct_id,
        ballot_response_id,
        blr_el.css('votes').first.content
      ]
    end

    cr.ballot_response_results.import(BALLOT_RESPONSE_RESULTS_COLUMNS, results) unless results.blank?
  end

  def temp
    for_each_precinct do |precinct_el, precinct|
      precinct.total_cast = precinct_el.css('total_cast').first.content
      precinct.save

      for_each_candidate(precinct_el) do |candidate_el, candidate|
        CandidateResult.create!(precinct_id: precinct.id, candidate_id: candidate.id, votes: candidate_el.css('votes').first.content)
      end

      for_each_ballot_response(precinct_el) do |br_el, br|
        BallotResponseResult.create!(precinct_id: precinct.id, ballot_response_id: br.id, votes: br_el.css('votes').first.content)
      end
    end
  end

  def for_each_precinct(&block)
    @doc.css('precinct').each do |precinct_el|
      precinct = Precinct.find_by_uid!(precinct_el['id'])
      block.call precinct_el, precinct
    end
  end

  def for_each_candidate(precinct_el, &block)
    precinct_el.css('candidate').each do |candidate_el|
      candidate = Candidate.find_by_uid!(candidate_el['id'])
      block.call candidate_el, candidate unless candidate.blank?
    end
  end

  def for_each_ballot_response(precinct_el, &block)
    precinct_el.css('ballot_response').each do |br_el|
      ballot_response = BallotResponse.find_by_uid(br_el['id'])
      block.call br_el, ballot_response unless ballot_response.blank?
    end
  end

end
