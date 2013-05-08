# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Static Page" do 
  subject { page }

  describe "Home Page" do
    before { visit home_path }

    it { should have_content("This is the home page for the Simple App.") }
    it { should have_selector('h1', text: "Welcome to the Simple App") }
    it { should have_selector("title", full_title("Home"))}

    describe "for signed_in user" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem Ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Hi~")
        sign_in user
        visit root_path
      end
      it { should have_content(user.feed.count) }
      it "should list the user' feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "followed/following count" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
         other_user.follow!(user)
         visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end
    end
  end

  describe "Help page" do
    before { visit help_path }

    it { should have_content("Help") }
    it { should have_selector("h1", text: "Help") }
    it { should have_selector("title", full_title("Help"))}
  end
end
