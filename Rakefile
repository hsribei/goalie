require File.dirname(__FILE__) + "/lib/goalie/version.rb"

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gemspec|
    gemspec.version = Goalie::VERSION
    gemspec.name = "goalie"
    gemspec.summary = "Custom error pages for Rails"

    gemspec.description = "Middleware to catch exceptions and " <<
      "Rails Engine to render them. Error-handling views and " <<
      "controllers can be easily overriden."

    gemspec.email = "helder@gmail.com"
    gemspec.homepage = "http://github.com/obvio171/goalie"
    gemspec.authors = ["Helder Ribeiro"]
    gemspec.add_dependency 'actionpack', '>= 3.0.0'
    gemspec.add_dependency 'activesupport', '>= 3.0.0'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
