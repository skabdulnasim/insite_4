class OwnCustomerAddress < ActiveRecord::Base
  attr_accessible :own_customer_id, :city, :contact_no, :landmark, :latitude, :longitude, :pincode, :state  

  has_many :reservations
end
