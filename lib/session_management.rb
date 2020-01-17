module SessionManagement
  
##########################
## Get current user id.. if session based then will get by current_user... either will get from param[tab]
##########################
  def get_current_user_id()
    if params[:user_id]
      @current_user_id = params[:user_id]
    else
      @current_user_id = current_user.id
    end
    return @current_user_id
  end

##########################
end