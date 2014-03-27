class ContestResult < ActiveRecord::Base

  belongs_to :precinct
  belongs_to :contest
  belongs_to :referendum

  has_many   :candidate_results,       dependent: :delete_all
  has_many   :ballot_response_results, dependent: :delete_all

  def contest_related?
    self.contest_id.present?
  end

  def referendum_related?
    self.referendum_id.present?
  end

end
