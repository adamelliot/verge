require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "verge"
    gem.summary = %Q{Lightweight centralized authentication system built on Sinatra}
    gem.description = %Q{Simple system that grants trusted sites tokens if users have successfully authenticated. So they are free to interact with each other securely.}
    gem.email = "adam@wartube.com"
    gem.homepage = "http://github.com/adamelliot/verge"
    gem.authors = ["Adam Elliot"]
    gem.add_dependency "sinatra", ">= 0.9.4"
    gem.add_dependency "datamapper", ">= 0.10.1"
    gem.add_dependency "bcrypt-ruby", ">= 2.0.5"
    gem.add_dependency "activesupport", ">= 2.3.4"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "factory_girl"
    gem.add_development_dependency "rack-test", ">= 0.5.0"
    gem.add_development_dependency "do_sqlite3", ">= 0.9.0"
    
    gem.executables = ['verge']
  end
  Jeweler::GemcutterTasks.new
#  Jeweler::RubyforgeTasks.new do |rubyforge|
#    rubyforge.doc_task = "yardoc"
#  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_opts = %W{--options \"#{File.dirname(__FILE__)}/spec/spec.opts\"}
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.spec_opts = %W{--options \"#{File.dirname(__FILE__)}/spec/spec.opts\"}
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = lambda do
     IO.readlines("#{File.dirname(__FILE__)}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
   end
end

task :spec => :check_dependencies

begin
  require 'reek/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
