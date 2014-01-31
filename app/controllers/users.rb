Bitcoinsms.controllers :users do
  get "/" do
    @user = User.new
    render '/users/new'
  end
  
  get "/new" do
    @user = User.new
    render '/users/new'
  end
  
  post "/" do
    @user = User.new(params[:user])
    if @user.save
      puts "======================================="
      puts @user.activation_code
      puts "======================================="
      
      deliver_email(@user.cell_with_provider, "", "Your bitcoinsms confirmation code is: #{@user.activation_code}")
      redirect '/users/confirmation'
    else
      flash[:error] = "Something wrong happened. Try again, please."
      render "/users/new"
    end
  end
  
  get "/confirmation" do
    render "/users/confirmation"
  end
  
  post "/activate" do
    @user = User.where(:activation_code => params[:activation_code]).first
    if @user && @user.activate!
      render "/users/activate"
    else
      flash[:error] = "Invalid confirmation code. Maybe you mistyped it."
      render "/users/confirmation"
    end
  end
  
  get "/:private_url" do
    @user = User.where(:private_url => params[:private_url]).first
    if @user
      render "/users/show"
    else
      render "/users/invalid_private_url"
    end
  end

  put "/:private_url" do
    @user = User.find(:first, :conditions => {:private_url => params[:private_url]})
    raise Sinatra::NotFound unless @user
    if @user.update_attributes(params[:user])
      flash[:notice] = "You successfully updated your settings."
      redirect "/users/#{@user.private_url}"
    else
      flash[:error] = "There was an error below."
      render "/users/show"
    end
  end
  
  # post "/send_private_url" do
  #   # have to grab all users in case, someone signed up their cell with the wrong provider initially. This way the message gets sent to each, and one of those will get to the user
  #   @users = get_users_by_cell(params[:user_cell])
  #   
  #   if @users.empty? == false
  #     send_private_url_mailer(@users)
  #     render "/users/send_private_url"
  #   else
  #     flash[:error] = "#{params[:user_cell]} is not a subscriber. Try again."
  #     redirect '/private/not-a-subscriber'
  #   end
  # end
  
  # get "/unsubscribe" do
  #   @user = User.new
  #   render "/users/unsubscribe"
  # end
  # 
  # post "/unsubscribe_confirmation" do
  #   @users = get_users_by_cell(params[:user_cell])
  #   
  #   if @users.empty? == false  
  #     @users.each do |user|
  #       user.update_attributes(:unsubscribe_code => generate_unsubscribe_code)
  #       deliver_unsubscribe_email(user.reload)
  #     end
  #       
  #     render "/users/unsubscribe_confirmation"
  #   else
  #     flash[:error] = "#{params[:user_cell]} is not a subscriber"
  #     redirect '/users/unsubscribe'
  #   end
  # end
  # 
  # post "/unsubscribe_finalize" do
  #   @user = User.find(:first, :conditions => {:unsubscribe_code => params[:unsubscribe_code]})
  #   raise Sinatra::NotFound unless @user
  #   @user.destroy
  #   
  #   begin
  #     message = TMail::Mail.new
  #     message.from = "a@missmint.com"
  #     message.to = "scott@scottmotte.com"
  #     message.subject = "Unsubscriber on MissMint.com :("
  #     message.content_type = "text/plain"
  #     message.body = "Unsubscriber was: #{@user.cell}@#{@user.provider}"
  #     message.tag = "missmint"
  #     message.reply_to = "a@missmint.com"
  #     Postmark.send_through_postmark(message)      
  #   rescue
  #   end
  #   
  #   render '/users/unsubscribe_finalize'
  # end
  
end