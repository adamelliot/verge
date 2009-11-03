require 'optparse'
require 'yaml'

module Verge
  module Server
    class Exec
      def initialize(argv)
        options = {}
        signature = nil
        database = nil
        signature_file = nil

        OptionsParser.new do |opts|
          opts.banner "Usage: verge [options]"
          # Sinatra params
          opts.on('-x')         {       options[:lock] = true }
          opts.on('-s server')  { |val| options[:server] = val }
          opts.on('-e env')     { |val| options[:environment] = val.to_sym }
          opts.on('-p port')    { |val| options[:port] = val.to_i }

          # Verge params
          opts.on('-g generic-signature') { |val| signature = val }
          opts.on('-d database')          { |val| database = val }
          opts.on('-S signature-file')    { |val| signature_file = val }

          opts.on_tail('-h', '--help', "Show this message") { puts opts ; exit }
        end

        Verge::Server::Config.database_path = database unless database.nil?
        Verge::Server::Config.generic_signature = signature unless signature.nil?

        begin
          YAML.load_file(signature_file).each do |key, value|
            Verge::Server::Config.site_signatures[key] = value
          end unless signature_file.nil?
        rescue
          puts "Can't read signature file!"
        end

        if Verge::Server::Site.count == 0
          token = Verge::Crypto.token
          Verge::Server::Config.generic_signature = token
          puts "Verge created the GENERIC_HOST token:\n#{token}\n"
        end

        Verge::Server::Base.run! options
      end
    end
  end
end