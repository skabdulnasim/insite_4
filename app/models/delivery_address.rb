class DeliveryAddress < ActiveRecord::Base
	attr_accessible		:pincode, :address, :latitude, :longitude
	has_and_belongs_to_many :units
	belongs_to :unit_customers

	# validates :latitude, :presence => true
	# validates :longitude, :presence  => true


	geocoded_by :address
  after_validation :geocode
  reverse_geocoded_by :latitude, :longitude, :address => :address

  scope :check_address, lambda {|pincode|where(["pincode=?",pincode])}



  # Address searching
  def self.search_by_address(search)  
    if search.present?  
      where("lower(delivery_addresses.address) LIKE ?", "%#{search.downcase}%")
    else  
      all  
    end  
  end

end
