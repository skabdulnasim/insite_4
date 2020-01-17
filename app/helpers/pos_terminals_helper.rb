module PosTerminalsHelper
  def setup_customer customer
    customer.customer_profile ||= CustomerProfile.new
    customer.resource ||= Resource.new
    customer
  end  
end
