# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require "bundler/setup"
Bundler.require(:development, :test)
require "storext"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
