require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
 
describe Verge::Client do
  it "returns the correct script tag" do
    Verge::Client.server_url = "http://login.example.com"

    extend Verge::Client::AssetHelper
    verge_javascript_tag.should eql('<script type="text/javascript" src="http://login.example.com/token.js"></script>')
  end
end
