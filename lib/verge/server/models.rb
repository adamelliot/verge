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

      has n, :user_keys, :expiry.gt => DateTime.now

      validates_is_unique :login

      before :destroy, :destroy_keys

      def generate_key(expiry = nil)
        user_keys.create(expiry && {:expiry => expiry} || {})
      end

      def valid_key
        user_keys.count > 0 ? user_keys.first : generate_key
      end

      def self.authenticate(login, password)
        u = User.first(:login => login)
        if !u.nil? && u.password == password
          u.valid_key
          u
        end
      end

      private

      def destroy_keys
        user_keys.all.destroy
      end
    end

    class SignedKey
      include DataMapper::Resource

      property :id,       Serial,   :key => true
      property :value,    String,   :length => 128..128, :nullable => false

      belongs_to :user_key
      belongs_to :site

      validates_is_unique :value
    end

    class UserKey
      TERMINAL_EPOCH = DateTime.new(4000) # Distant future

      include DataMapper::Resource

      property :id,       Serial,   :key => true
      property :value,    String,   :length => 128..128,  :default => lambda { Verge::Crypto.token }
      property :expiry,   DateTime, :nullable => false,   :default => TERMINAL_EPOCH

      belongs_to :user
      has n, :signed_keys

      before :destroy, :destroy_signed_keys
      after :create, :sign

      private

      def sign
        Site.all.each do |site|
          site.sign_key(self)
        end
      end

      def destroy_signed_keys
        signed_keys.destroy
      end
    end

    class Site
      include DataMapper::Resource

      property :id,         Serial, :key => true
      property :uri,        String, :length => 12..300
      property :signature,  String, :length => 128..128, :default => lambda { Verge::Crypto.token }

      has n, :signed_keys

      validates_is_unique :uri
      validates_is_unique :signature

      before :destroy, :destroy_signed_keys
      after :create, :sign_keys

      def sign_key(user_key)
        signed_keys.create(:value => Verge::Crypto.digest(signature, user_key.value), :user_key => user_key)
      end

      def self.find_by_url(url)
        return nil if url.nil?
        uri = url[/^([A-Za-z\d]*(:\/\/){0,1}[^\/]*)/, 1]
        Site.first(:uri => uri)
      end

      private

      def sign_keys
        UserKey.all(:expiry.gt => DateTime.now).each do |user_key|
          sign_key(user_key)
        end
      end

      def destroy_signed_keys
        signed_keys.destroy
      end
    end

    DataMapper.auto_migrate!
  end
end