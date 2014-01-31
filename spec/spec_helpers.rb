def empty_database
  User.delete_all
end

module UserSpecHelper
  # ===============================
  # User helpers
  # ===============================
  def valid_user_attributes(options = {})
    { :cell => '555-433-7543',
      :provider => 'txt.att.net',
      :timezone_offset => -8,
      :remind_at_hour => 7 }.merge(options)
  end

  def valid_second_user_attributes(options = {})
    { :cell => '444.644.8654',
      :provider => 'vtext.com',
      :timezone_offset => -8,
      :remind_at_hour => 7 }.merge(options)
  end
  
  def user_exists
    @user = User.new(valid_user_attributes)
    @user.save!
  end
end