class ResqueEat
  if PADRINO_ENV == "production"
    extend HerokuResqueAutoScale 
  end
  
  @queue = :resque_eat
  
  def self.perform(food)
    begin
      to      = "scott@scottmotte.com"
      subject = "Ate #{food}!"
      from    = "support@#{AppConfig[:site_url]}"
      body    = "You ate the food: #{food}"

      mail = Mail.new
      mail[:to]           = to
      mail[:subject]      = subject
      mail[:body]         = body
      mail[:from]         = from
      mail.deliver!
    rescue
    end
  end
end

class ResqueSendNotifications
  if PADRINO_ENV == "production"
    extend HerokuResqueAutoScale 
  end
  
  @queue = :resque_send_notifications
  
  def self.perform
    Rule.send_notifications!
  end
end