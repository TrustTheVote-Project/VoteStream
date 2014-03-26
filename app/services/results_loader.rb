class ResultsLoader < BaseLoader

  def initialize(xml_source)
    @xml_source = xml_source
    @doc = Nokogiri::XML(xml_source)
    @doc.remove_namespaces!
  end

  def load
    @districts = {}
    @precinct_ids = {}
    @candidate_ids = {}
    @ballot_response_ids = {}

    Precinct.transaction do
      remove_old_results
      load_new_results

      DataProcessor.on_results_upload
    end
  end

  private

  def remove_old_results
    ContestResult.destroy_all
  end

  def load_new_results
    contest_uids    = @doc.css('contest_result > contest_id').map { |el| dequote(el.content) }
    contest_ids     = Contest.where(uid: contest_uids).select('uid, id').inject({}) { |m, r| m[r.uid] = r.id; m }
    referendum_uids = @doc.css('contest_result > referendum_id').map { |el| dequote(el.content) }
    referendum_ids  = Referendum.where(uid: referendum_uids).select('uid, id').inject({}) { |m, r| m[r.uid] = r.id; m }

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

      cr = ContestResult.create!({
        uid:               cr_el['id'],
        certification:     cr_el['certification'],
        precinct_id:       precinct_id,
        contest_id:        contest_id,
        referendum_id:     referendum_id,
        total_votes:       total_votes,
        total_valid_votes: cr_el.css('> total_valid_votes').first.content
      })

      if contest_id
        load_contest_results(cr_el, cr)
      elsif referendum_id
        load_referendum_results(cr_el, cr)
      else
        raise InvalidFormat.new("Neither contest_id, nor referendum_id elements found")
      end
    end
  end

  def load_contest_results(cr_el, cr)
    results = []

    cr_el.css('ballot_line_result').each do |blr_el|
      candidate_uid = dequote(blr_el.css('> candidate_id').first.content)
      candidate_id = @candidate_ids[candidate_uid] || (@candidate_ids[candidate_uid] = Candidate.find_by!(uid: candidate_uid).id)

      results << {
        uid:         blr_el['id'],
        precinct_id: cr.precinct_id,
        candidate_id: candidate_id,
        votes:       blr_el.css('votes').first.content
      }
    end

    cr.candidate_results.create(results) unless results.blank?
  end

  def load_referendum_results(cr_el, cr)
    results = []

    cr_el.css('ballot_line_result').each do |blr_el|
      ballot_response_uid = dequote(blr_el.css('> ballot_response_id').first.content)
      ballot_response_id = @ballot_response_ids[ballot_response_uid] || (@ballot_response_ids[ballot_response_uid] = BallotResponse.find_by!(uid: ballot_response_uid).id)

      results << {
        uid:         blr_el['id'],
        precinct_id: cr.precinct_id,
        ballot_response_id: ballot_response_id,
        votes:       blr_el.css('votes').first.content
      }
    end

    cr.ballot_response_results.create(results) unless results.blank?
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
