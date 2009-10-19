require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
 
describe Verge::Crypto do
  it "returns a sha512 token" do
    Verge::Crypto.token.length.should == 128
  end
  
  it "creates a hash for multiple values entered" do
    Verge::Crypto.digest("some", "values").length.should == 128
  end
end
