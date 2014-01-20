class DataProcessor

  def self.default_category(locality)
    Rails.cache.fetch("locality:#{locality.id}:default_category") do
      dts = locality.contests.select('DISTINCT contests.district_type').map(&:district_type)
      district_order = [ 'Federal', 'State', 'MCD', 'Other' ]
      (district_order & dts).first || DataController::CATEGORY_REFERENDUMS
    end
  end

  def self.percent_reporting(locality)
    Rails.cache.fetch("locality:#{locality.id}:percent_reporting") do
      all_pids  = locality.precinct_ids
      reporting = BallotResponseResult.where(precinct_id: all_pids).select("DISTINCT precinct_id").map(&:precinct_id)
      reporting << CandidateResult.where(precinct_id: all_pids).select("DISTINCT precinct_id").map(&:precinct_id)
      reporting = reporting.uniq

      puts reporting.count, all_pids.count

      v = (reporting.count * 100.0) / [ all_pids.count, 1 ].max
      "%3.1f" % v
    end
  end

  def self.on_definitions_upload
    on_results_upload
  end

  def self.on_results_upload
    Rails.cache.delete_matched("locality:*")
  end

end
