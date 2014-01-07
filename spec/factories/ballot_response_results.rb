FactoryGirl.define do
  factory :ballot_response_result do
    ballot_response
    precinct
    votes { rand 1000 }
  end
end
