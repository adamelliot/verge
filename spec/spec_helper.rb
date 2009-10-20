$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'verge'
require 'spec'
require 'spec/autorun'
require 'rack/test'
require 'factory_girl'

require File.expand_path(File.dirname(__FILE__)) + '/factories'

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods

  # Add an app method for RSpec
  def app
    Rack::Lint.new(Verge::Server::Base.new)
  end
end
