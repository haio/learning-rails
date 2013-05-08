FactoryGirl.define do
  factory :user do 
    sequence(:name) { |n| "Example user-#{n}" }
    sequence(:email) { |n| "Example-#{n}@example.com" }
    password  "please"
    password_confirmation "please"

    factory :admin do
      admin true
    end
  end
end