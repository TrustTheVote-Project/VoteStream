FactoryGirl.define do
  factory :candidate_vote do
    contest_result
    candidate
    precinct
    votes { rand 1000 }
  end
end
