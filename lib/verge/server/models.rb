require 'dm-core'
require 'dm-aggregates'
require 'dm-validations'
require 'dm-types'
require 'dm-timestamps'

require 'activesupport'

DataMapper::setup(:default, ENV['DATABASE_URL'] || Verge::Server::Config.database_path)

module Verge
  module Server
    class User
      include DataMapper::Resource

      property :id,         Serial,     :key => true
      property :login,      String,     :nullable => false, :length => 1..255
      property :password,   BCryptHash
      property :activated,  Boolean,    :default => false, :nullable => false
      property :expiry,     DateTime,   :default => lambda { DateTime.now + 1.day }

      has n, :tokens, :expiry.gt => DateTime.now

      validates_is_unique :login

      before :destroy, :destroy_tokens

      # Generates a new token for this user.
      def generate_token(expiry = nil)
        tokens.create(expiry && {:expiry => expiry} || {})
      end

      # Returns a valid token for this user. If no tokens exist on is created
      def token
        tokens.count > 0 ? tokens.first : generate_token
      end
      
      # Marks this user as valid. Invalid users will be destroyed after their
      # expiry passes.
      def activate!
        activated = true
        expiry = nil
        save
      end

      # Attempts to find a user based on the credentials passed.
      def self.authenticate(login, password)
        user = User.first(:login => login)
        (user.nil? || user.password != password) && nil || user
      end

      # Removes expired users
      def self.remove_expired_users
        User.all(:expiry.lt => DateTime.now).destroy
      end

      private

      def destroy_tokens
        tokens.all.destroy
      end
    end

    class SignedToken
      include DataMapper::Resource

      property :id,       Serial,   :key => true
      property :value,    String,   :length => 128..128, :nullable => false

      belongs_to :token
      belongs_to :site

      validates_is_unique :value
    end

    class Token
      TERMINAL_EPOCH = DateTime.new(4000) # Distant future

      include DataMapper::Resource

      property :id,       Serial,   :key => true
      property :value,    String,   :length => 128..128,  :default => lambda { Verge::Crypto.token }
      property :expiry,   DateTime, :nullable => false,   :default => TERMINAL_EPOCH

      belongs_to :user
      has n, :signed_tokens

      before :destroy, :destroy_signed_tokens
      after :create, :sign

      private

      def sign # nodoc #
        Site.all.each do |site|
          site.sign_token(self)
        end
      end

      def destroy_signed_tokens # nodoc #
        signed_tokens.destroy
      end
    end

    # Datastructure representing a site that will connect and authenticate
    # against verge. If you've setup verge with just one generic site key
    # none of your sites will need to specify who they are and should
    # all share that common key.
    class Site
      # Set a value that will be used to look up keys that are not associated
      # with a particular site
      GENERIC_HOST = "generic.hostname"
      
      include DataMapper::Resource

      property :id,         Serial, :key => true
      property :host,       String, :length => 3..300
      property :signature,  String, :length => 128..128, :default => lambda { Verge::Crypto.token }

      has n, :signed_tokens

      validates_is_unique :host
      validates_is_unique :signature

      before :destroy, :destroy_signed_tokens
      after :create, :sign_tokens
      
      # Prepends this sites token to the string list and runs a digest over
      # the new string.
      def sign(*args)
        Verge::Crypto.digest(signature, args.join)
      end

      # Takes a token for a user and signs it creating a new hash
      def sign_token(token)
        signed_tokens.create(:value => sign(token.user.login, token.value), :token => token)
      end

      # Searchs all the sites for ones that match the host
      #   EG:
      #    "http://verge.example.com/some/path?id=1" will match
      #    "verge.example.com"
      def self.find_by_uri(uri)
        return nil if uri.nil?
        Site.first(:host => uri[/^([A-Za-z\d]*\:\/\/){0,1}([^\/]*)/, 2])
      end

      private

      def sign_tokens # nodoc #
        Token.all(:expiry.gt => DateTime.now).each do |token|
          sign_token(token)
        end
      end

      def destroy_signed_tokens # nodoc #
        signed_tokens.destroy
      end
    end

    DataMapper.auto_migrate!
  end
end