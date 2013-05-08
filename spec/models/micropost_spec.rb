# -*- encoding : utf-8 -*-
require "spec_helper"

describe Micropost do
  let(:user) { FactoryGirl.create(:user) }
  before { @post = user.microposts.build(content: "beautiful girl") }
  subject { @post }

  it { should be_valid }
  it { should respond_to :content }
  it { should respond_to :user }
  its(:user) { should == user }

  describe "when content is empty" do 
    before { @post.content = " " }
    it { should_not be_valid }
    specify { @post.save.should be_false }
  end

  describe "when content is longer than 140" do 
    before { @post.content = "p" * 141 }
    it { should_not be_valid }
  end

  describe "when user_id is not present" do
    before { @post.user_id = nil }
    it { should_not be_valid }
  end

  describe "accessible attribute" do
    it "should not allow to access user_id" do
      expect { Micropost.new(user_id: 1) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
end