class Address < ActiveRecord::Base
  attr_accessible :city, :contact_no, :customer_id, :delivery_address, :landmark, :latitude, :locality, :longitude, :pincode, :place, :receiver_first_name, :receiver_last_name, :receiver_name, :state, :address_type

  belongs_to :customer
  belongs_to :additional_information, :class_name => "Customer"
  has_many :orders, as: :deliverable

  # before_validation :set_attributes
  after_create :set_attributes

  # Adding address geocoding
  geocoded_by :delivery_address
  after_validation :geocode
  reverse_geocoded_by :latitude, :longitude, :delivery_address => :delivery_address

  default_scope { order('updated_at desc') } 

  # def receiver_name=(name)
  #   name = name.split(' ')
  #   self.receiver_first_name = name[0]
  #   self.receiver_last_name = name[1]
  # end

  # def receiver_name
  #   receiver_first_name.present? ? "#{receiver_first_name} #{receiver_last_name}" : ""
  # end

  private

    def set_attributes
      update_attribute(:locality, self.landmark) unless locality.present?
      update_attribute(:receiver_first_name, self.customer.customer_profile.firstname) unless receiver_first_name.present?
      update_attribute(:receiver_last_name, self.customer.customer_profile.lastname) unless receiver_last_name.present?
      update_attribute(:contact_no, self.customer.mobile_no) unless contact_no.present?
    end
end