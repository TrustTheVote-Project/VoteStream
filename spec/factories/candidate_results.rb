FactoryGirl.define do
  factory :candidate_vote do
    candidate
    precinct
    votes { rand 1000 }
  end
end
