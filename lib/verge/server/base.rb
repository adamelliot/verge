module Verge
  module Server
    class Base < Sinatra::Base
      get '/auth' do
        site = Site.find_by_url(params[:target])
        halt 401, "Bad site." if site.nil?

        user = User.authenticate(params[:login], params[:password])
        halt 401, "Bad user." if user.nil?

        response.set_cookie("token", {
          :value => user.valid_token.value,
          :path => '/'
        })
        user.valid_token.value
      end

      get '/verify/:token' do |token|
        site = Site.find_by_url(request.referer)
        halt 401, "Not a valid site." if site.nil?

        signed_token = site.signed_tokens.first(:value => token)
        halt 404, "Token not found." if signed_token.nil?
      end
    end
  end
end