class DataProcessor

  def self.default_category(locality)
    Rails.cache.fetch("locality:#{locality.id}:default_category") do
      dts = locality.contests.select('DISTINCT contests.district_type').map(&:district_type)
      district_order = [ 'Federal', 'State', 'MCD', 'Other' ]
      (district_order & dts).first || RefConResults::CATEGORY_REFERENDUMS
    end
  end

  def self.percent_reporting(locality)
    stats = precinct_stats(locality)
    v = (stats[:reporting_precinct_ids].count * 100.0) / [ stats[:precinct_count], 1 ].max
    if v >= 100
      "Final Results"
    elsif v > 0
      "%3.1f" % v + " % Reporting"
    else
      "No Results"
    end
  end

  def self.reporting_precinct_ids(locality)
    stats = precinct_stats(locality)
    stats[:reporting_precinct_ids]
  end

  def self.precinct_stats(locality)
    Rails.cache.fetch("locality:#{locality.id}:precinct_stats") do
      all_pids  = locality.precinct_ids
      reporting = BallotResponseResult.where(precinct_id: all_pids).select("DISTINCT precinct_id").map(&:precinct_id)
      reporting << CandidateResult.where(precinct_id: all_pids).select("DISTINCT precinct_id").map(&:precinct_id)
      reporting = reporting.flatten.uniq

      { precinct_count: all_pids.count,
        reporting_precinct_ids: reporting }
    end
  end

  # returns IDs of districts that doesn't cover whole range of precincts
  def self.focused_district_ids(locality)
    Rails.cache.fetch("locality:#{locality.id}:focused_district_ids") do
      precinct_count = locality.precincts.count
      precinct_ids   = locality.precinct_ids
      DistrictsPrecinct.where(precinct_id: precinct_ids).group("district_id").having("count(*) < #{precinct_count}").pluck(:district_id)
    end
  end

  def self.on_definitions_upload
    on_results_upload
  end

  def self.on_results_upload
    Rails.cache.delete_matched("locality:*")
  end

end
