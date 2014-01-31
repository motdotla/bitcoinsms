PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  ##
  # You can handle all padrino applications using instead:
  #   Padrino.application
  Bitcoinsms.tap { |app|  }
end

# include all the spec helpers
require File.expand_path(File.dirname(__FILE__) + "/spec_helpers")

include UserSpecHelper