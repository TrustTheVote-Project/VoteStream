FactoryGirl.define do
  factory :polling_location do
    precinct
    address
    sequence(:name) { |n| "Polling location #{n}" }
  end
end
