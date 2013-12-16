FactoryGirl.define do
  factory :election do
    state
    sequence(:uid) { |n| "election_#{n}" }
    held_on       "2013-12-16"
    election_type "Federal"
    statewide     true
  end
end
