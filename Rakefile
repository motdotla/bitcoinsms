require File.expand_path('../config/boot.rb', __FILE__)
require 'padrino-core/cli/rake'

require 'resque/tasks'
# http://blog.redistogo.com/2010/07/26/resque-with-redis-to-go/
task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

PadrinoTasks.init
