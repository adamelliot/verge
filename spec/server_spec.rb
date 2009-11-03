require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module ServerSpecHelper
  def valid_auth_request(user, redirect = "", site = "")
    {:login => user.login, :password => "0rbital", :redirect => redirect, :site => site}
  end
  
  def new_user_credentials_for_site(site)
    login = 'new-verge-user'
    {:login => login, :password => '0rbital', :signature => site.sign(login)}
  end
end

describe Verge::Server do
  include ServerSpecHelper

  before :each do
    @site = Factory(:site)
    header("Referer", @site.host)
  end

  describe "GET to /token.js" do
    it "echos cookie back in javascript" do
      login = "astro"
      token = "bombastic"

      set_cookie("login=#{login}")
      set_cookie("token=#{token}")

      get '/token.js'
      last_response.body.should =~ /#{login}/
      last_response.body.should =~ /#{token}/
    end

    it "echos nothing if no cookies are sent" do
      get '/token.js'
      last_response.body.should == ""
      last_response.should be_ok
    end
    
    it "echos nothing if login is blank" do
      set_cookie("login=")
      set_cookie("token=a-token")

      get '/token.js'
      last_response.body.should == ""
      last_response.should be_ok
    end

    it "echos nothing if login is blank" do
      set_cookie("login=a-login")
      set_cookie("token=")

      get '/token.js'
      last_response.body.should == ""
      last_response.should be_ok
    end
  end
  

  describe 'POST to /login' do
    before :each do
      @user = Factory(:user)
    end

    it 'fails with empty request' do
      post '/login'
      last_response.status.should == 401
    end

    it 'returns a code when valid' do
      post '/login', valid_auth_request(@user)
      last_response.body.should == "token=#{@user.token.value}"
    end
    
    it 'sets a cookie on success' do
      post '/login', valid_auth_request(@user)
      last_response.headers["Set-Cookie"].should == "token=#{@user.token.value}; path=/"
    end
    
    it 'redirects to the desired target with the token' do
      post '/login', valid_auth_request(@user, "http://example.com")

      last_response.status.should == 302
      last_response.headers["Location"].should == "http://example.com?token=#{@user.token.value}"
    end

    it 'redirects to the desired target with the token and detects other url params' do
      post '/login', valid_auth_request(@user, "http://example.com?snowball=cat")

      last_response.status.should == 302
      last_response.headers["Location"].should == "http://example.com?snowball=cat&token=#{@user.token.value}"
    end
  end
  
  describe "POST to /create" do
    before :each do
      Verge::Server::User.all.destroy!
    end
    
    it "fails if site not found" do
      header("Referer", "BAD://SITE")
      post '/create'

      last_response.status.should == 401
    end
    
    it "creates a new user" do
      post '/create', new_user_credentials_for_site(@site)
      last_response.should be_ok
      last_response.body.should == Verge::Server::User.first.token.value
    end
  end

  describe 'GET to /verify/:token' do
    before :each do
      @user = Factory(:user)
      @signed_token = @user.token.signed_tokens.first(:site_id => @site.id)
      
      header("Referer", @site.host)
    end
 
    it "fails if no regisered site is found" do
      header("Referer", "BAD://SITE")
      get "/verify/anything"

      last_response.status.should == 401
    end
    
    it "fails if token can't be found" do
      get "/verify/anything"
      
      last_response.status.should == 404
    end
    
    it "succeeds if the token is valid" do
      get "/verify/#{@signed_token.value}"

      last_response.should be_ok
    end
  end
end