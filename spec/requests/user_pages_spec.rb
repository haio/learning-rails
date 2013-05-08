require 'spec_helper'

describe "UserPages" do
  subject { page }

  describe "Signup page" do 
    before { visit signup_path }
    let(:submit) { "Create my account" }

    it "should have title 'Sign up'" do 
      page_title(page).should eq(full_title("Sign up"))
    end
    it { should have_selector("h1", text: "Sign up") }

    describe "signup with invalid data" do 
      it "should not create a user" do 
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "signup with valid data" do 
      let(:user) { FactoryGirl.build(:user) }
      before do 
        fill_in "Name",         with: user.name
        fill_in "Email",        with: user.email
        fill_in "Password",     with: user.password
        fill_in "Confirmation", with: user.password_confirmation
      end
      it "should create a user" do 
        expect { click_button submit }.to change(User, :count).by(1)
      end
    end
  end

  describe "Profile page" do 
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "post-1") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "post-2") }
    before do
     sign_in user
     visit user_path(user)
   end

    it { should have_selector("h1", text: user.name ) }

    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }

      describe "follow user" do
        before { visit user_path(other_user) }

        it "should increase the followed user count" do
          expect { click_button "Follow" }.to change(user.followed_users, :count).by(1)
        end

        it "should increase the followers count" do
          expect { click_button "Follow" }.to change(other_user.followers, :count).by(1)
        end

        describe "it should toggle the follow button" do
          before { click_button "Follow" }
          it { should have_button("Unfollow") }
        end
      end

      describe "unfollow user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrease the followed user count" do
          expect { click_button "Unfollow" }.to change(user.followed_users, :count).by(-1)
        end

        it "should decrease the followers count" do
          expect { click_button "Unfollow" }.to change(other_user.followers, :count).by(-1)
        end

        describe "it should toggle the unfollow button" do
          before { click_button "Unfollow" }
          it { should have_button("Follow") }
        end
      end
    end
  end

  describe "Settings page" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      visit signin_path
      sign_in user
      click_link "Settings"
    end
    
    it { should have_selector("h1", text: "Update your profile") }
    it { should have_link("Change") }

    describe "when edit with valid information" do
      let(:new_name) { "new" + user.name }
      let(:new_email) { "new" + user.email }

      before do
        fill_in "Name",       with: new_name
        fill_in "Email",      with: new_email
        fill_in "Password",   with: user.password
        fill_in "Confirmation", with: user.password_confirmation
        click_button "Save changes"
      end

      it {should have_selector("div.alert.alert-success", text: "Profile updated") }
      it {should have_link("Sign out", href: signout_path) }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

  describe "Index page" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_selector("h1", text:"All users") }
    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }
    
      it { should have_selector("div.pagination") }
      it "should list each users" do
        User.page(1).each do |user|
          page.should have_selector("li", text: user.name)
        end
      end
    end

    describe "delete link" do
      it { should_not have_link("link") }

      describe "as a admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link("delete", href: user_path(User.first)) }
        it { should_not have_link("delete", href: user_path(admin)) }
        it "should be delete another user" do
          expect { click_link("delete") }.to change(User, :count).by(-1)
        end
      end

      describe "as a none-admin user" do
        let(:none_admin) { FactoryGirl.create(:user) }
        let(:user) { FactoryGirl.create(:user) }

        describe "submiting a delete action to destroy user" do
          before { delete user_path(user) }

          specify { response.should redirect_to(root_path) }
        end
      end
    end
  end

  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_selector("h3", text: "Following") }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_selector("h3", text: "Followers") }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end
end