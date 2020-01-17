module DeliveryBoysHelper
  def log_in(delivery_boy)
    session[:delivery_boy_id] = delivery_boy.id
  end
  # Returns the current logged-in user (if any).
  def current_delivery_boy
    @current_delivery_boy ||= DeliveryBoy.find(session[:delivery_boy_id])
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_delivery_boy.nil?
  end
  def check_availability(delivery_boy_id)
    Order.check_avlty_delivery_boy(delivery_boy_id)
  end
end
