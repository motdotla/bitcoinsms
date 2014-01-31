# taken from http://railstips.org/blog/archives/2009/11/10/config-so-simple-your-mama-could-use-it/
module AppConfig
  # Allows accessing config variables from harmony.yml like so:
  # AppConfig[:domain] => harmonyapp.com
  def self.[](key)
    unless @config
      raw_config = File.read(PADRINO_ROOT + "/config/app_config.yml")
      @config = YAML.load(raw_config)[PADRINO_ENV].symbolize_keys
    end
    @config[key]
  end
  
  def self.[]=(key, value)
    @config[key.to_sym] = value
  end
end