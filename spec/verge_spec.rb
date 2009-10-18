require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module VergeSpecHelper
  def valid_auth_request_for(user, site)
    {:login => user.login, :password => "0rbital", :target => site.uri}
  end

  def auth_request_without_target_for(user)
    {:login => user.login, :password => user.password}
  end
end

describe Verge do
  include VergeSpecHelper
  
  before :each do
    @site = Factory(:site)
    @user = Factory(:user)
  end
  
  describe 'authentication' do
    it 'fails with empty request' do
      get '/auth'
      last_response.headers["Status"] =~ /401/
    end

    it 'returns a code when valid' do
      get '/auth', valid_auth_request_for(@user, @site)
      last_response.body.should == @user.valid_key.value
    end
    
    it 'sets a cookie on success' do
      get '/auth', valid_auth_request_for(@user, @site)
      last_response.headers["Set-Cookie"] = "key=#{@user.valid_key.value}"
    end
  end

  describe 'verification' do
    before :each do
      @user = Factory(:user)
      @site = Factory(:site)
      @signed_key = @user.valid_key.signed_keys.first
      
      header("Referer", @site.uri)
    end
 
    it "fails if no regisered site is found" do
      header("Referer", "BAD://SITE")
      get "/verify/anything"

      last_response.headers["Status"] =~ /401/
    end
    
    it "fails if key can't be found" do
      get "/verify/anything"
      
      last_response.headers["Status"] =~ /404/
    end
    
    it "succeeds if the key is valid" do
      get "/verify/#{@signed_key.value}"

      last_response.headers["Status"] =~ /200/
    end
  end
end