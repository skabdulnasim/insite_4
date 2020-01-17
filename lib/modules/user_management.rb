module UserManagement
##########################
#### get current user info
##########################
  
  def self.get_current_user(id)
  	puts "user_id :  #{id}"
    @current_user = User.find(id)
    return @current_user
  end

##########################
#### get current user profile
##########################
  
  def self.get_current_user_profile(id)
    @current_user_profile = Profile.where(:user_id => id)
    return @current_user_profile[0]
  end
end