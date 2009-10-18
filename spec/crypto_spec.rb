require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
 
describe Verge::Crypto do
  it "should return a sha512 token" do
    Verge::Crypto.token.length.should == 128
  end
  
  it "should create a hash for multiple values entered" do
    Verge::Crypto.digest("some", "values").length.should == 128
  end
end
