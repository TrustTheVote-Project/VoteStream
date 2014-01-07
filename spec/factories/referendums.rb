# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :referendum do
    title "MyString"
    subtitle "MyText"
    question "MyText"
    sort_order "MyString"
    district nil
  end
end
