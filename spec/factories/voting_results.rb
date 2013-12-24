FactoryGirl.define do
  factory :voting_result do
    candidate
    precinct
    votes { rand 1000 }
  end
end
