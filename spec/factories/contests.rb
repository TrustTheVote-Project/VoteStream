FactoryGirl.define do
  factory :contest do
    district
    sequence(:uid) { |n| "contest_#{n}" }
    office "Judge"
    sequence(:sort_order) { |n| n }
  end
end
