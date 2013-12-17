FactoryGirl.define do
  factory :address do
    sequence(:line1) { |n| "Line 1: #{n}" }
    city  "ARDEN HILLS"
    state "MN"
    zip   "55126"
  end
end
