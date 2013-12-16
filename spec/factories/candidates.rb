FactoryGirl.define do
  factory :candidate do
    contest
    sequence(:uid) { |n| "candidate_#{n}" }
    name "John Smith"
    party "Nonpartisan"
    sequence(:sort_order) { |n| n }
  end
end
