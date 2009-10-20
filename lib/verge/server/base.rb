module Verge
  module Server
    class Base < Sinatra::Base
      # Request from clients (browers generally) to authenticate with username
      # and password. Returns a token that should be sent back to the site
      # along with the login passed here to be verified by the site
      # as allowed to login.
      get '/auth' do
        extract_site

        user = User.authenticate(params[:login], params[:password])
        halt 401, "Bad user." if user.nil?

        set_cookie_for_user(user)
        user.token.value
      end

      get '/token.js' do
        @token = request.cookies["token"]
        @login = request.cookies["login"]

        erb 'token.js'.to_sym unless @token.blank? || @login.blank?
      end

      # Creates user accounts
      post '/create' do
        extract_site

        user = User.new(:login => params[:login], :password => params[:password])
        halt 400, "Could not create user." unless user.save

        # TODO: Make user activation not manditory, for now ther is no activation mechanism
        user.activate!

        user.token.value
      end

      # Verifies if a token passed to a site is valid and checks that it
      # properly matches the user requesting it.
      # 
      # This is called from the sites themselves to verify that the token
      # being passed from the client isn't spoofed and can be trusted to 
      # be the user they say they are.
      get '/verify/:token' do |token|
        signed_token = extract_site.signed_tokens.first(:value => token)
        halt 404, "Token not found." if signed_token.nil?
      end
      
      set :views, File.dirname(__FILE__) + '/views'

      private

      def extract_site # nodoc #
        site = Site.find_by_url(request.referer)
        (site.nil? && halt(401, "Not a valid site.")) || site
      end

      def set_cookie_for_user(user) # nodoc #
        response.set_cookie("token", {
          :value => user.token.value,
          :path => '/'
        })
      end
    end
  end
end
