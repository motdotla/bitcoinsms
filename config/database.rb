database_name = case Padrino.env
  when :development then 'bitcoinsms_development'
  when :test        then 'bitcoinsms_test'
  when :production  then 'bitcoinsms_production'
end
host = case Padrino.env
  when :development then 'localhost'
  when :test        then 'localhost'
  when :production  then 'flame.mongohq.com'
end
port = case Padrino.env
  when :development then Mongo::Connection::DEFAULT_PORT
  when :test        then Mongo::Connection::DEFAULT_PORT
  when :production  then '27108'
end

# Connection.new takes host, port
Mongoid.database = Mongo::Connection.new(host, port).db(database_name)
Mongoid.database.authenticate('bitcoinsms', 'password') if Padrino.env == :production

# Redis stuff
if Padrino.env == :production
  # ENV["REDISTOGO_URL"] ||= "redis://username:password@host:1234/"
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  Resque.redis = Redis.new(:host => "localhost", :port => 6379)
end

# # Redis stuff
# if Padrino.env == :production
#   # ENV["REDISTOGO_URL"] ||= "redis://username:password@host:1234/"
#   uri = URI.parse(ENV["REDISTOGO_URL"])
#   Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
# else
#   Resque.redis = Redis.new(:host => "localhost", :port => 6379)
# end
