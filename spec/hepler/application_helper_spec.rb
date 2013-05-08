require "spec_helper"

describe "ApplicationHelper" do
  describe "full_title" do
    it "should included in the title" do 
      full_title("foo").should =~ /foo/
    end

    it "should has a base title" do 
      full_title("foo").should =~ /Pants Review/
    end

    it "should not has a bar in home page" do 
      full_title("").should_not =~ /\|/
    end
  end
end