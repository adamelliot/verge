require 'rubygems'
require 'sinatra'
require 'haml'
require 'erb'
require 'cgi'

require 'dm-core'
require 'dm-aggregates'
require 'dm-validations'
require 'dm-types'
require 'dm-timestamps'

require File.join(File.dirname(__FILE__), "verge", "crypto")
require File.join(File.dirname(__FILE__), "verge", "server", "base")
require File.join(File.dirname(__FILE__), "verge", "server", "models")

module Verge
  VERSION = '0.0.1'
end
