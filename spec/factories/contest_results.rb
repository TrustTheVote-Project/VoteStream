FactoryGirl.define do
  factory :contest_result do
    certification "unofficial_partial"
    contest
    precinct     { |o| o.contest.precinct }
    referendum   nil
    total_votes  1
    total_valid_votes 1
  end
end
