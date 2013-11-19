$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'singleton'

require 'active_support/core_ext'
require 'rspec'
require 'sys/proctable'
require 'memory_tracker'
require 'memory_tracker/gc_stat'
require 'memory_tracker/request'
require 'memory_tracker/memory_tracker'
require 'memory_tracker/stores/base'
require 'memory_tracker/stores/loader'
require 'memory_tracker/stores/in_memory_store'
require 'memory_tracker/stores/gcstat_logfile_store'
require 'memory_tracker/stores/url_logfile_store'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
# require 'rspec/rails'
# require 'rspec/mocks/standalone'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}


RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
#   config.mock_with :rspec
end

class Rails
  def self.root
    ''
  end
end

