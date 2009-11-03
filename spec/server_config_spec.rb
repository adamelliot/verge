require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
 
describe Verge::Server::Config do
  before :all do
    Verge::Server::Site.all.destroy
    Verge::Server::Token.all.destroy

    @token = Verge::Crypto::token
  end

  it "has a default database path" do
    Verge::Server::Config.database_path.should_not be_nil
  end
  
  it "sets sqlite3 as the db type if not specified" do
    Verge::Server::Config.database_path = "login.db"
    Verge::Server::Config.database_path.should == "sqlite3://login.db"
  end
  
  it "sets the generic site's token" do
    Verge::Server::Config.generic_signature = @token
    Verge::Server::Config.site_signatures[Verge::Server::Site::GENERIC_HOST].should == @token
  end

  it "has the GENERIC_HOST with the specified token" do
    Verge::Server::Config.generic_signature = @token
    Verge::Server::Site.count.should == 1
  end
  
end
