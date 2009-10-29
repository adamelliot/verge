module Verge
  module Client
    class << self
      attr_accessor :server_url
    end

    module AssetHelper
      # Return the javascript tag that include the token if the user's authenticated
      def verge_javascript_tag
        "<script type=\"text/javascript\" src=\"#{Verge::Client.server_url}/token.js\"></script>"
      end
    end
    
    module PathHelper
      # Return the path to the authentication action on the server
      def verge_auth_url
        "#{Verge::Client.server_url}/login"
      end
    end
  end
end

# If using rails add the verge_javascript_tag to action view
::ActionView::Base.send(:include, Verge::Client::AssetHelper) if defined? ::ActionView::Base
::ActionView::Base.send(:include, Verge::Client::PathHelper) if defined? ::ActionView::Base
