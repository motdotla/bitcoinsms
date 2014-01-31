# Defines our constants
PADRINO_ENV  = ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= "development"  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, PADRINO_ENV)

##
# Enable devel logging
#
# Padrino::Logger::Config[:development] = { :log_level => :devel, :stream => :stdout }
# Padrino::Logger.log_static = true
#

##
# Add your before load hooks here
#
Padrino.before_load do
end

##
# Add your after load hooks here
#
Padrino.after_load do
  if Padrino.env == :development
    coffeescript_dir = File.expand_path(Padrino.root("app/javascripts/"), File.dirname(__FILE__))
    Barista.output_root = "public/javascripts/compiled"
    # Barista.bare = true # don't wrap the compiled JS in a .call(this) Closure
    Barista::Framework.register 'leaderboard', coffeescript_dir
  end
end

Padrino.load!