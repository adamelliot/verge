module Verge
  module Client
    class << self
      attr_accessor :server_url
    end

    module AssetHelper
      def verge_javascript_tag
        "<script type=\"text/javascript\" src=\"#{Verge::Client.server_url}/token.js\"></script>"
      end
    end
  end
end

# If using rails add the verge_javascript_tag to action view
::ActionView::Base.send(:include, Verge::Client::AssetHelper) if defined? ::ActionView::Base
