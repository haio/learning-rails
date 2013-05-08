require 'spec_helper'

describe "AuthenticationPages" do
  subject { page }
  describe "Sign in page" do
    before { visit signin_path }

    it { should have_selector("h1","Sign in") }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector("div.alert.alert-error", text: "Invalid") }

      describe "after visit aonther page" do
        before { visit home_path }
        it { should_not have_selector("div.alert.alert-error", text: "Invalid") }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      it { should have_link("Users", href: users_path) }
      it { should have_link("Profile", href: user_path(user)) }
      it { should have_link("Sign out", href: signout_path) }
      it { should_not have_link("Sign up", href: signup_path) }
      it { should have_link("Settings", href: edit_user_path(user)) }

      describe "followed by sign out" do
        before { click_link "Sign out" }
        it { should have_selector("div.alert.alert-success",text: "Sign out successfully") }
        it { should have_link("Sign in", href: signin_path) }
      end
    end
  end

  describe "Authorization" do
    describe "for the none-signed-in user" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the user controller" do
        describe "when visit the edit path" do
          before { visit edit_user_path(user) }
          it { should have_selector("h1", text:"Sign in") }
        end

#         When using one of the methods to issue HTTP requests directly, we get access to
# the low-level response object. Unlike the Capybara page object, response lets us test
# for the server response itself, in this case verifying that the update action responds by
# redirecting to the signin page:
        describe "when submit a update action" do
          before { put user_path(user) }
          #it { should have_selector("h1","Sign in") }
          specify { response.should redirect_to(signin_path) }
        end

        describe "when visit the users path" do
          before { visit users_path }
          it { should have_selector("h1", text: "Sign in") }
        end

        describe "when visit the following path" do
          before { visit following_user_path(user) }
          it { should have_selector("h1", text: "Sign in") }
        end

        describe "when visit the followers path" do
          before { visit followers_user_path(user) }
          it { should have_selector("h1", text: "Sign in") }
        end
      end

      describe "when visit the protected page" do
        before { visit edit_user_path(user) }
        it { should have_selector("h1",text: "Sign in") }

        describe "after sign in" do
          before do
            fill_in "Email", with: user.email
            fill_in "Password", with: user.password
            click_button "Sign in"
            cookies[:remember_token] = user.remember_token
          end

          it { should have_selector("h1", text: "Update your profile") }
        end
      end

      describe "in the Micropost controller" do

        describe "submitting the create action" do
          before { post microposts_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting the destroy action" do
          let(:post) { FactoryGirl.create(:micropost) }
          before { delete micropost_path(post) }
          specify { response.should redirect_to(signin_path) }
        end
      end

      describe "in the Relationship controller" do
        describe "submitting the create action" do
          before { post relationships_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting the destroy action" do
          before  { delete relationship_path(1) }
          specify { response.should redirect_to(signin_path) }
        end
      end
    end

    describe "as a wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong_user@example.com") }
      before { sign_in user }

      describe "when visit the edit path" do
        before { visit edit_user_path(wrong_user) }
        it { should have_selector("h1","Welcome to the Pant Review") }
      end

      describe "when submit a update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end
  end
end
