module Verge
  module Server
    module Config
      class << self
        attr_reader :database_path, :site_signatures

        # Make sure the DB path has a type, defaults to sqlite3 if not
        # specified.
        def database_path=(val)
          @database_path = val.index("://").nil? ? "sqlite3://#{val}" : val
          load_signatures
        end

        # Set the generic site's token, if only one token is to be shared
        # across all sites.
        def generic_signature=(val)
          @site_signatures[Verge::Server::Site::GENERIC_HOST] = val
        end
        
        def site_signatures=(val)
          #::Verge::Server::Site.all.destroy!
          
          val.instance_eval do
            def []=(key, val)
              super
              Verge::Server::Config.load_signatures
            end
          end
          
          @site_signatures = val
          load_signatures
        end

        # Loads the signatures from the config into sites
        def load_signatures
          return if @site_signatures.nil?
          @site_signatures.each do |host, signature|
            site = Site.first(:host => host) || Site.new(:host => host)
            site.signature = signature
            site.save
          end
        end

      end
      
      self.database_path = "sqlite3://#{Dir.pwd}/verge.sqlite3"
      self.site_signatures = {}
    end
  end
end