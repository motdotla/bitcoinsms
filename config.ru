require ::File.dirname(__FILE__) + '/config/boot.rb'
# run Padrino.application

require 'resque/server'
run Rack::URLMap.new("/" => Padrino.application, "/resque" => Resque::Server.new)