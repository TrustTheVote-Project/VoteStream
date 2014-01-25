FactoryGirl.define do
  factory :district do
    sequence(:uid) { |n| "district_#{n}" }
    sequence(:name) { |n| "District #{n}" }
    district_type "Federal"
  end
end
