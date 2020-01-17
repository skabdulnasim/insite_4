class OwnerRegistration < ActiveRecord::Base
  resourcify
  attr_accessible :name, :address, :email_id, :owner_name, :phone, :web_link, :resturant_image
  #validates :name, :owner_name, :address, :phone, :email_id, :presence => true
end
