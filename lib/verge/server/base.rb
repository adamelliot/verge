module Verge
  module Server
    class Base < Sinatra::Base
      get '/auth' do
        site = Site.find_by_url(params[:target])
        halt 401, "Bad site." if site.nil?

        user = User.authenticate(params[:login], params[:password])
        halt 401, "Bad user." if user.nil?

        response.set_cookie("key", {
          :value => user.valid_key.value,
          :path => '/'
        })
        user.valid_key.value
      end

      get '/verify/:key' do |key|
        site = Site.find_by_url(request.referer)
        halt 401, "Not a valid site." if site.nil?

        signed_key = site.signed_keys.first(:value => key)
        halt 404, "Key not found." if signed_key.nil?
      end
    end
  end
end