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
    CandidateResult.delete_all
    BallotResponseResult.delete_all
  end

  def load_new_results
    @doc.css('contest_result').each do |cr_el|
      precinct_uid = dequote(cr_el.css('> jurisdiction_id').first.content)
      precinct_id = @precinct_ids[precinct_uid]

      unless precinct_id
        precinct = Precinct.find_by!(uid: precinct_uid)
        precinct_id = @precinct_ids[precinct_uid] = precinct.id
        precinct.total_cast = cr_el.css('> total_votes').first.content
        precinct.save
      end

      if cr_el.css('> contest_id').length > 0
        load_contest_results(precinct_id, cr_el)
      elsif cr_el.css('> referendum_id').length > 0
        load_referendum_results(precinct_id, cr_el)
      else
        raise InvalidFormat.new("Neither contest_id, nor referendum_id elements found")
      end
    end
  end

  def load_contest_results(precinct_id, cr_el)
    cr_el.css('ballot_line_result').each do |blr_el|
      candidate_uid = dequote(blr_el.css('> candidate_id').first.content)
      candidate_id = @candidate_ids[candidate_uid] || (@candidate_ids[candidate_uid] = Candidate.find_by!(uid: candidate_uid).id)

      CandidateResult.create!(precinct_id: precinct_id, candidate_id: candidate_id, votes: blr_el.css('votes').first.content)
    end
  end

  def load_referendum_results(precinct_id, cr_el)
    cr_el.css('ballot_line_result').each do |blr_el|
      ballot_response_uid = dequote(blr_el.css('> ballot_response_id').first.content)
      ballot_response_id = @ballot_response_ids[ballot_response_uid] || (@ballot_response_ids[ballot_response_uid] = BallotResponse.find_by!(uid: ballot_response_uid).id)

      BallotResponseResult.create!(precinct_id: precinct_id, ballot_response_id: ballot_response_id, votes: blr_el.css('votes').first.content)
    end
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
