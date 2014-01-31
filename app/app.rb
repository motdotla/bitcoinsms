class Bitcoinsms < Padrino::Application
  set :haml, :format => :html5 # sets haml to html5  
  
  configure do
    enable :raise_errors
    
    register SassInitializer
    register Padrino::Mailer
    register Padrino::Helpers
    
    # Application configuration options
    enable    :sessions           # Disabled by default
    enable    :flash              # Disables rack-flash (enabled by default if sessions)
    # mail gem
    Mail.defaults do
      delivery_method :smtp, { :address              => "smtp.sendgrid.net",
                               :port                 => 25,
                               :domain               => ENV['SENDGRID_DOMAIN'],
                               :user_name            => ENV['SENDGRID_USERNAME'],
                               :password             => ENV['SENDGRID_PASSWORD'],
                               :authentication       => :plain,
                               :enable_starttls_auto => true  }
    end
  end


  configure :development do
    Mail.defaults do
      delivery_method :test
    end
  end

  configure :test do
    Mail.defaults do
      delivery_method :test
    end
  end
  
  get "/" do
    redirect '/users/new'
  end
  
  get "/signup" do
    redirect '/users/new'
  end
  
  get "/subscribe" do
    redirect '/users/new'
  end
  
  get "/signup/confirmation" do
    redirect '/users/confirmation'
  end
  
  get "/subscribe/confirmation" do
    redirect '/signup/confirmation'
  end
  
  get "/private/:private_url" do
    redirect "/users/#{params[:private_url]}"
  end
  
  get "/unsubscribe" do
    redirect "/users/unsubscribe"
  end
  
  get "/unsubscribe/finalize" do
    redirect "/users/unsubscribe_finalize"
  end
  
  # NEW METHODS
  post "/users/:user_id/rules" do
    @user = User.where(:_id => params[:user_id]).first
    @rule = @user.rules.build(params[:rule])
    if @rule.save!
      flash[:error] = "Success!"
      redirect "/users/#{@user.private_url}"
    else
      flash[:error] = "Something wrong happened. Try again, please."
      redirect "/users/#{@user.private_url}"
    end
  end
  
  
  
  
  # helpers - should be private probably, and ideally should go in their prospective controllers
  def get_users_by_cell(cell)
    cell = cell.gsub(/\D/,'') rescue "" # remove dashes from cell
    if cell.empty? == false 
      @users = User.find(:all, :conditions => {:cell => cell})
    else
      @users = []
    end
  end
  
  def send_private_url_mailer(users)
    users.each do |user|
      user.update_attributes(:private_url => generate_private_url)
      # send_mail(ActivationMailer, :send_private_url, { :from => AppConfig.site.email, :to => "#{user.cell}@#{user.provider}" }, { :user => user })
      deliver_private_url_email(user)
    end
  end
 
  def generate_private_url
    Digest::SHA1.hexdigest( Date.today.to_s.split(//).sort_by {rand}.join )
  end
  
  def send_unsubscribe_mailer(users)    
    users.each do |user|
      user.update_attributes(:unsubscribe_code => generate_unsubscribe_code)
      # send_mail(ActivationMailer, :unsubscribe, { :from => AppConfig.site.email, :to => "#{user.cell}@#{user.provider}" }, { :user => user })
      deliver_unsubscribe_email(user)
    end
  end
  
  def generate_unsubscribe_code
    chars = ("a".."z").to_a
    unsubscribe_code = ""
    1.upto(6) { |i| unsubscribe_code << chars[rand(chars.size-1)] }
    return unsubscribe_code
  end
  
  def secret_url(user)
    "http://#{AppConfig[:site_url]}/private/#{user.private_url}"
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
  
  
  # OLD DELIVERY STUFF FOR POSTMARK
  # def deliver_signup_email(user)
  #   message = TMail::Mail.new
  #   message.from = "a@bitcoinsms.com"
  #   message.to = "#{user.cell}@#{user.provider}"
  #   message.subject = ""
  #   message.content_type = "text/plain"
  #   message["Message-Id"] = "<#{user.cell}@#{user.provider}>"
  #   message.body = "Your Bitcoinsms confirmation code is: #{user.activation_code}"
  #   message.tag = "bitcoinsms"
  #   message.reply_to = "a@bitcoinsms.com"
  #   Postmark.send_through_postmark(message)
  #   user.update_attributes(:activation_sent => true)
  # end
  # 
  # def deliver_private_url_email(user)
  #   message = TMail::Mail.new
  #   message.from = "a@bitcoinsms.com"
  #   message.to = "#{user.cell}@#{user.provider}"
  #   message.subject = ""
  #   message.content_type = "text/plain"
  #   message["Message-Id"] = "<#{user.cell}@#{user.provider}>"
  #   message.body = "Your private page is: #{secret_url(user)}"
  #   message.tag = "bitcoinsms"
  #   message.reply_to = "a@bitcoinsms.com"
  #   Postmark.send_through_postmark(message)
  # end
  # 
  # def deliver_unsubscribe_email(user)
  #   message = TMail::Mail.new
  #   message.from = "a@bitcoinsms.com"
  #   message.to = "#{user.cell}@#{user.provider}"
  #   message.subject = ""
  #   message.content_type = "text/plain"
  #   message["Message-Id"] = "<#{user.cell}@#{user.provider}>"
  #   message.body = "Your unsubscribe code is: #{user.unsubscribe_code}"
  #   message.tag = "bitcoinsms"
  #   message.reply_to = "a@bitcoinsms.com"
  #   Postmark.send_through_postmark(message)
  #   user.update_attributes(:unsubscribe_sent => true)
  #   true
  # end
end