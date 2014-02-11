FactoryGirl.define do
  factory :party do
    sequence(:uid) { |n| n.to_s }
    sequence(:sort_order) { |n| n }
    name { |o| "Party #{o.uid}" }
    abbr { |o| "P#{o.uid}" }
  end
end
