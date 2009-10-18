require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Verge::Server::User do
  before :each  do
    Verge::Server::UserKey.all.destroy!
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

  it "creates a key after successful login" do
    user = Verge::Server::User.authenticate(@user.login, "0rbital")
    user.user_keys.count.should eql(1)
  end
  
  it "creates a key with an expiry" do
    expiry = DateTime.now + 100
    @user.generate_key(expiry)
    @user.user_keys.first.expiry.should eql(expiry)
  end
  
  it "destroys any keys that belong to it when destroyed" do
    @user.valid_key
    @user.destroy
    Verge::Server::UserKey.count.should eql(0)
  end
  
  it "valid key returns an existing key when one's been created" do
    @user.generate_key
    count = @user.user_keys.count
    @user.valid_key
  
    @user.user_keys.count.should eql(count)
  end
  
  it "valid key creates a new key when none exist" do
    count = @user.user_keys.count
    @user.valid_key
    
    @user.user_keys.count.should eql(count + 1)
  end
end

describe Verge::Server::SignedKey do
  before :each do
    @signed_key = Factory(:signed_key)
  end
  
  it "doesn't allow duplicate signatures" do
    Factory(:signed_key, :value => @signed_key.value).should_not be_valid
  end
end

describe Verge::Server::UserKey do
  before :each do
    Verge::Server::SignedKey.all.destroy!
    Verge::Server::UserKey.all.destroy!
    Factory(:site)

    @user_key = Verge::Server::UserKey.create(:user_id => 1)
  end
  
  it "has a valid token" do
    @user_key.value.length.should eql(128)
  end
  
  it "has a user_id" do
    new_user_key = Verge::Server::UserKey.new
    new_user_key.user_id.should be_nil
    new_user_key.should_not be_valid
  end
  
  it "destroys any signed keys that belong to it when destroyed" do
    @user_key.destroy
    Verge::Server::SignedKey.count.should eql(0)
  end
  
  it "automatically creates signed keys for each site when created" do
    Verge::Server::Site.count.should eql(Verge::Server::SignedKey.count)
  end
end

describe Verge::Server::Site do
  before :each do
    Verge::Server::Site.all.destroy!
    Verge::Server::User.all.destroy!
    Verge::Server::UserKey.all.destroy!
    Verge::Server::SignedKey.all.destroy!
    
    @user = Factory(:user)
    @site = Factory(:site)
  end
  
  it "returns valid key after signing key" do
    @site.sign_key(Verge::Server::User.first.valid_key).value.length.should == 128
  end

  it "destroys any signed keys that belong to it when destroyed" do
    Verge::Server::UserKey.create(:user_id => 1)
    @site.signed_keys.destroy
    Verge::Server::SignedKey.count.should eql(0)
  end
  
  it "signs any keys that haven't expired when created" do
    @user.valid_key
    Verge::Server::SignedKey.count.should eql(Verge::Server::Site.count)
    # Factory(:site) uses create! which will bypass the after hook
    Factory.build(:site).save.should be_true
    Verge::Server::SignedKey.count.should eql(Verge::Server::Site.count)
  end
  
  it "returns a site when the domain and protocol match" do
    site1 = Factory(:site)
    site2 = Verge::Server::Site.find_by_url("#{site1.uri}/some/other/path?junk=10&true=false")
    site2.should_not be_nil
    site2.uri.should eql(site1.uri)
  end
  
  it "should create a valid signed key when signing" do
    @user.valid_key.should_not be_nil
    Verge::Server::SignedKey.count.should eql(1)
    signature = Verge::Crypto.digest(@site.signature, @user.valid_key.value)
    Verge::Server::SignedKey.first.value.should == signature
  end
end








