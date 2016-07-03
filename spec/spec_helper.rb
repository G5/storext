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

RSpec.configure do |c|
  c.before :suite do
    DatabaseCleaner.clean_with(:truncation, {
      except: %w(public.ar_internal_metadata),
    })
  end

  c.before do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  c.after do
    DatabaseCleaner.clean
  end
end
