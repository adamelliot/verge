require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
 
describe Verge::Client do
  before :all do
    Verge::Client.server_url = "http://login.example.com"
  end
  
  it "returns the correct script tag" do
    extend Verge::Client::AssetHelper

    verge_javascript_tag.should == '<script type="text/javascript" src="http://login.example.com/token.js"></script>'
  end
  
  it "should return the authentication path to the verge server" do
    extend Verge::Client::PathHelper
    
    verge_auth_url.should == "http://login.example.com/login"
  end
end
