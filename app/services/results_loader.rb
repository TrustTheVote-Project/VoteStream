class ResultsLoader

  class InvalidFormat < StandardError; end

  def initialize(xml_source)
    @xml_source = xml_source
    @doc = Nokogiri::XML(xml_source)
    @doc.remove_namespaces!
    @districts = {}
  end

  def load
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
