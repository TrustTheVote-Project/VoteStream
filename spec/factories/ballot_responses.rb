# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ballot_response do
    referendum nil
    name "MyString"
    sort_order "MyString"
  end
end
