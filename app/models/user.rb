class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Schema
  field :cell,                      :type => String
  field :cell_alias,                :type => String
  field :provider,                  :type => String
  field :activation_code,           :type => String
  field :activated_at,              :type => DateTime
  field :activation_sent,           :type => Boolean, :default => false
  field :private_url,               :type => String
  field :unsubscribe_code,          :type => String
  field :unsubscribe_sent,          :type => Boolean, :default => false
  
  # Relationships
  has_many :rules
  
  # Validations
  validates_presence_of   :cell
  validates_presence_of   :provider, :message => "must not be blank"
  validates_length_of     :cell, :is => 10, :message => "must be 10 characters long. e.g. 310-555-7653"
  validates_length_of     :private_url, :minimum => 15, :maximum => 100, :on => :update
  validates_uniqueness_of :private_url
  validate                :cell_with_provider_is_unique
  
  # Callbacks
  before_validation :clean_cell
  before_create     :make_activation_code
  before_create     :make_private_url
  
  # Scopes - like named scopes in rails
  def self.active
    criteria.where(:activation_code => 'activated')
  end
  
  def self.not_active
    criteria.excludes(:activation_code => 'activated')
  end
  
  # Methods
  
  def cell_with_provider
    "#{cell}@#{provider}"
  end
  
  def active?
    return false if new_record?
    return true if activation_code == 'activated'
    return false
  end
  
  alias_method :activated?, :active?
  
  # Activates and saves the user.
  def activate!
    self.reload unless new_record? # Make sure the model is up to speed before we try to save it
    self.activated_at = DateTime.now
    self.activation_code = 'activated'
    self.save!
    
    begin
      deliver_email(cell_with_provider, "", "You're subscription is successfully confirmed! Thanks. ~BitcoinSMS")
    rescue
    end
    
    begin
      deliver_email("scott@scottmotte.com", "", "New signup at BitcoinSMS.com!")
    rescue
    end
    
    true
  end
  
  private
  def clean_cell
    # replace any non-digit with no space
    self.cell = cell.gsub(/\D/,'') rescue "" # set nil cell to empty value
  end
  
  def make_activation_code
    # cell phone code
    chars = ("a".."z").to_a
    start_code = ""
    1.upto(6) { |i| start_code << chars[rand(chars.size-1)] }
    self.activation_code = start_code
  end
  
  def make_private_url
    self.private_url = Digest::SHA1.hexdigest( Date.today.to_s.split(//).sort_by {rand}.join + self.cell)
  end
  
  def cell_with_provider_is_unique
    num = User.where(:cell => cell, :provider => provider).count
    if new_record? 
      return true if num <= 0
      errors.add(:cell, "is already taken. It is possible you already signed up. If so, then you just need to <a href='/subscribe/confirmation'>confirm your subscription</a> if not already.")
    else
      return true if num <= 1
      errors.add(:cell, "is already taken.")
    end
  end
  
  def deliver_email(to, subject, body, from=AppConfig[:text_from])
    return if to.blank?
    mail = Mail.new
    mail[:to]           = to
    mail[:subject]      = subject
    mail[:body]         = body
    mail[:from]         = from
    mail.deliver!
  end
end
