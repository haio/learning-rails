require 'spec_helper'

describe "MicropostPages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do
      it "should not create a post" do
        expect { click_button "Post" }.to_not change(Micropost, :count)
      end

      describe "it should have error messages" do
        before { click_button "Post" }
        it { should have_content("error") }
      end
    end

    describe "with valid information" do
      before { fill_in "micropost_content", with: "Lorem ipsum" }
      it "should create a post" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "as a correct user" do
    before do
      FactoryGirl.create(:micropost, user: user)
      visit root_path
    end
    it "should delete a micropost" do
      expect { click_link "delete" }.to change(Micropost, :count).by(-1)
    end
  end
end
