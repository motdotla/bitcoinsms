Bitcoinsms.controllers :api_v1 do     
  get "/help/test", :provides => [:js, :json] do
    "ok".to_json
  end
  
  get "/help/eat/:food", :provides => [:js, :json] do
    Resque.enqueue(ResqueEat, params[:food])
    "ok".to_json
  end
  
  get "/send_notifications", :provides => [:js, :json] do
    Resque.enqueue(ResqueSendNotifications)
    "ok".to_json
  end
  
  delete "/users/:user_id/rules/destroy/:id", :provides => [:js, :json] do
    @user   = User.where(:_id => params[:user_id]).first
    @rule   = @user.rules.where(:_id => params[:id]).first if @user
    if @user && @rule
      @rule.destroy
      @rule.as_hash.to_json
    else
      [404, {'content-type'=>'text/plain'}, "Not Found".to_json]
    end
  end
  
  
  # get "/mtgox/last", :provides => [:js, :json] do
  #   response = Typhoeus::Request.get("https://mtgox.com/code/data/ticker.php")
  #   json = JSON response.body
  #   last = "#{json['ticker']['last']}"
  #   deliver_email('scott@scottmotte.com', "", "MtGOX: #{last}")
  #   last.to_json
  # end
end