# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :micropost do 
    # association :user, factory: :user
    user
    content "first post..."
  end 
end