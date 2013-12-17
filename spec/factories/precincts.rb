FactoryGirl.define do
  factory :precinct do
    locality
    sequence(:uid) { |n| "precinct_#{n}" }
    sequence(:name) { |n| "Precinct #{n}" }
  end
end
