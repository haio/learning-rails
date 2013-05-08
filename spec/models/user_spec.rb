require "spec_helper"

describe User do 
  before { @user = User.new name: "User1", email: "user@example.com", password:"please", password_confirmation: "please" }
  subject { @user }

  it { should respond_to :name }
  it { should respond_to :email }
  it { should respond_to :password_digest }
  it { should respond_to :password }
  it { should respond_to :password_confirmation }
  it { should respond_to :authenticate }
  it { should respond_to :remember_token }
  it { should respond_to :admin }
  it { should respond_to :microposts }
  it { should respond_to :relationships }
  it { should respond_to :followed_users }
  it { should respond_to :following? }
  it { should respond_to :follow! }
  it { should respond_to :reverse_relationships }
  it { should respond_to :followers }

  it { should be_valid }
  it { should_not be_admin }

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "when name is not present" do 
    before { @user.name = "" }
    it { should_not be_valid }
  end

  describe "when name is longer than 50" do 
    before { @user.name = "n" * 51 }
    it { should_not be_valid }
  end

  describe "when email is not present" do 
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when email is valid" do 
    before { @user.email = "@example.com"}
    it { should_not be_valid }
  end

  describe "when email address is already taken" do 
    before do 
      user_with_same_email = @user.dup
      user_with_same_email.save!
    end

    it { should_not be_valid }
  end

  describe "when email address with mixed case" do 
    let(:mixed_case_email) { "user@ExamPle.COM" }

    it "should be saved in lower case" do 
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "when password is not present" do 
    before { @user.password = @user.password_confirmation = " " }

    it{ should_not be_valid }
  end

  describe "when password is shorter than 6" do 
    before { @user.password = @user.password_confirmation = "p" * 5 }

    it { should_not be_valid }
  end

  describe "when password doesn't match confiramtion" do 
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confiramtion is nil" do 
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "return value of authenticate method" do 
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid passwod" do 
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do 
      let(:invalid_user) { found_user.authenticate("invalid password") }
      it { should_not ==  invalid_user}
      specify { invalid_user.should be_false }
    end
  end

  describe "when set as admin" do
    before { @user.toggle!(:admin) }

    it { should be_admin }
  end

  describe "admin attr cant be mass asigned" do
    it "should raise exception" do
      expect do
        User.new(admin: true)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "microposts associations" do
    before { @user.save! }
    let!(:older_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) }
    let!(:newer_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) }

    describe "it should have the right microposts in right order" do
      its(:microposts) { should == [newer_micropost, older_micropost] }
    end

    it "should destroy associated microposts" do
      microposts = @user.microposts
      @user.destroy
      microposts.each do |post|
        Micropost.find_by_id(post.id).should be_nil
      end
    end

    describe "status" do
      let(:unfollowed_post) { FactoryGirl.create(:micropost, user: FactoryGirl.create(:user)) }
      let(:followed_user) { FactoryGirl.create(:user) }
      before do
        @user.follow!(followed_user)
        4.times { FactoryGirl.create(:micropost, user: @user, content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |post|
          should include(post)
        end
      end
    end

    describe "following" do
      let(:other_user) { FactoryGirl.create(:user) }
      before do
        @user.save
        @user.follow!(other_user)
      end

      it { should be_following(other_user) }
      its(:followed_users) { should include(other_user) }

      describe "and unfollowing" do
        before { @user.unfollow!(other_user) }
        
        it { should_not be_following(other_user) }
        its(:followed_users) { should_not include(other_user) }
      end

      describe "followed user" do
        subject { other_user }

        its(:followers) { should include(@user) }
      end
    end
  end
end