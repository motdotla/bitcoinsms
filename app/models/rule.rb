class Rule
  include Mongoid::Document
  
  # Relationships
  belongs_to :user
  
  # Schema
  field :latest_price_in_dollars,   :type => String
  field :notification_sent,         :type => DateTime
  
  # Methods
  def as_hash(options = {})
    {
      :id => id,
      :latest_price_in_dollars => latest_price_in_dollars
    }
  end
  
  def self.send_notifications!
    response  = Typhoeus::Request.get("https://mtgox.com/code/data/ticker.php")
    json      = JSON response.body
    last      = "#{json['ticker']['last']}"
    
    self.all.each do |r|
      begin
        if r.latest_price_in_dollars.to_f < last.to_f
          u = r.user
          deliver_email(u.cell_with_provider, "", "Bitcoin dropped to: #{last} (below your set price of #{r.latest_price_in_dollars})")
        end
      rescue
      end
    end
  end
  
  private
  
  def self.deliver_email(to, subject, body, from=AppConfig[:text_from])
    return if to.blank?
    mail = Mail.new
    mail[:to]           = to
    mail[:subject]      = subject
    mail[:body]         = body
    mail[:from]         = from
    mail.deliver!
  end
end