DataMapper::Logger.new("#{Dir.pwd}/../log/dm.log", :debug)
DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3:///#{Dir.pwd}/../db.sqlite3")

#configure do
#DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3:///#{Dir.pwd}/db.sqlite3")
#end

#configure :test do
#  DataMapper::setup(:default, "sqlite3:///#{Dir.pwd}/test.sqlite3")
#end


module Verge
  module Server
    class User
      include DataMapper::Resource

      property :id,       Serial,     :key => true
      property :login,    String,     :nullable => false, :length => 1..255
      property :password, BCryptHash

      has n, :tokens, :expiry.gt => DateTime.now

      validates_is_unique :login

      before :destroy, :destroy_tokens

      def generate_token(expiry = nil)
        tokens.create(expiry && {:expiry => expiry} || {})
      end

      def valid_token
        tokens.count > 0 ? tokens.first : generate_token
      end

      def self.authenticate(login, password)
        u = User.first(:login => login)
        if !u.nil? && u.password == password
          u.valid_token
          u
        end
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

      def sign
        Site.all.each do |site|
          site.sign_token(self)
        end
      end

      def destroy_signed_tokens
        signed_tokens.destroy
      end
    end

    class Site
      include DataMapper::Resource

      property :id,         Serial, :key => true
      property :uri,        String, :length => 12..300
      property :signature,  String, :length => 128..128, :default => lambda { Verge::Crypto.token }

      has n, :signed_tokens

      validates_is_unique :uri
      validates_is_unique :signature

      before :destroy, :destroy_signed_tokens
      after :create, :sign_tokens

      def sign_token(token)
        signed_tokens.create(:value => Verge::Crypto.digest(signature, token.value), :token => token)
      end

      def self.find_by_url(url)
        return nil if url.nil?
        uri = url[/^([A-Za-z\d]*(:\/\/){0,1}[^\/]*)/, 1]
        Site.first(:uri => uri)
      end

      private

      def sign_tokens
        Token.all(:expiry.gt => DateTime.now).each do |token|
          sign_token(token)
        end
      end

      def destroy_signed_tokens
        signed_tokens.destroy
      end
    end

    DataMapper.auto_migrate!
  end
end