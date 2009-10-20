require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Verge::Server::User do
  before :each  do
    Verge::Server::Token.all.destroy!
    Verge::Server::User.all.destroy!
    @user = Factory(:user)
  end
  
  it "doesn't allow duplicate logins" do
    Factory(:user, :login => @user.login).should_not be_valid
  end
  
  it "finds user when provided valid credentials" do
    Verge::Server::User.authenticate(@user.login, "0rbital").should_not be_nil
  end
  
  it "returns nil if no user is found for credentials" do
    Verge::Server::User.authenticate("nobody", "---").should be_nil
  end

  it "creates a token with an expiry" do
    expiry = DateTime.now + 100
    @user.generate_token(expiry)
    @user.tokens.first.expiry.should eql(expiry)
  end
  
  it "destroys any tokens that belong to it when destroyed" do
    @user.token
    @user.destroy
    Verge::Server::Token.count.should eql(0)
  end
  
  it "valid token returns an existing token when one's been created" do
    @user.generate_token
    count = @user.tokens.count
    @user.token
  
    @user.tokens.count.should eql(count)
  end
  
  it "valid token creates a new token when none exist" do
    count = @user.tokens.count
    @user.token
    
    @user.tokens.count.should eql(count + 1)
  end
  
  it "starts out as an inactive user and has an expiry" do
    @user.activated.should be_false
    @user.expiry.should >= DateTime.now + 4.minutes
  end
  
  it "will mark the model as activated and remove the expiry" do
    @user.activate!
  end
  
  it "removes any uses that have expired" do
    Factory(:user, :expiry => 1.minute.ago)
    count = Verge::Server::User.count
    Verge::Server::User.remove_expired_users
    Verge::Server::User.count.should == (count - 1)
  end
end

describe Verge::Server::SignedToken do
  before :each do
    @signed_token = Factory(:signed_token)
  end
  
  it "doesn't allow duplicate signatures" do
    Factory(:signed_token, :value => @signed_token.value).should_not be_valid
  end
end

describe Verge::Server::Token do
  before :each do
    Verge::Server::SignedToken.all.destroy!
    Verge::Server::Token.all.destroy!
    Factory(:site)
    @user = Factory(:user)

    @token = Verge::Server::Token.create(:user_id => @user.id)
  end
  
  it "has a valid token" do
    @token.value.length.should eql(128)
  end
  
  it "has a user_id" do
    new_token = Verge::Server::Token.new
    new_token.user_id.should be_nil
    new_token.should_not be_valid
  end
  
  it "destroys any signed tokens that belong to it when destroyed" do
    @token.destroy
    Verge::Server::SignedToken.count.should eql(0)
  end
  
  it "automatically creates signed tokens for each site when created" do
    Verge::Server::Site.count.should eql(Verge::Server::SignedToken.count)
  end
end

describe Verge::Server::Site do
  before :each do
    Verge::Server::Site.all.destroy!
    Verge::Server::User.all.destroy!
    Verge::Server::Token.all.destroy!
    Verge::Server::SignedToken.all.destroy!
    
    @user = Factory(:user)
    @site = Factory(:site)
  end
  
  it "returns valid token after signing token" do
    @site.sign_token(Verge::Server::User.first.token).value.length.should == 128
  end

  it "destroys any signed tokens that belong to it when destroyed" do
    Verge::Server::Token.create(:user_id => @user.id)
    @site.signed_tokens.destroy
    Verge::Server::SignedToken.count.should eql(0)
  end

  it "signs any tokens that haven't expired when created" do
    @user.token
    Verge::Server::SignedToken.count.should eql(Verge::Server::Site.count)
    # Factory(:site) uses create! which will bypass the after hook
    Factory.build(:site).save.should be_true
    Verge::Server::SignedToken.count.should eql(Verge::Server::Site.count)
  end
  
  it "returns a site when the host matches" do
    site1 = Factory(:site)
    site2 = Verge::Server::Site.find_by_uri("http://#{site1.host}/some/other/path?junk=10&true=false")
    site2.should_not be_nil
    site2.host.should eql(site1.host)
  end
  
  it "should create a valid signed token when signing" do
    @user.token.should_not be_nil
    Verge::Server::SignedToken.count.should eql(1)
    signature = Verge::Crypto.digest(@site.signature, @user.login, @user.token.value)
    Verge::Server::SignedToken.first.value.should == signature
  end
end
