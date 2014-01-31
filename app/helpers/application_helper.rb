# Helper methods defined here can be accessed in any controller or view in the application

Bitcoinsms.helpers do
  # def simple_helper_method
  #  ...
  # end
  def set_selected_provider(user)
    if user.new_record?
      :blank# "txt.att.net"
    else
      "#{user.provider}"
    end
  end
end