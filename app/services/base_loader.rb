class BaseLoader

  class InvalidFormat < StandardError; end

  def dequote(v)
    v.blank? ? v : v.gsub(/(^["']|["']$)/, '')
  end

  def raise_strict(ex)
    if AppConfig['enable_strict_vipplus_parsing']
      raise ex
    else
      puts ex.message
      Rails.logger.error ex.message
    end
  end

  def purge_locality_results(locality)
    contest_result_ids = ContestResult.where(contest_id: locality.contest_ids).pluck(:id)
    CandidateResult.where(contest_result_id: contest_result_ids).delete_all
    BallotResponseResult.where(contest_result_id: contest_result_ids).delete_all
    ContestResult.where(contest_id: locality.contest_ids).delete_all
    ContestResult.where(referendum_id: locality.referendum_ids).delete_all
  end

end
