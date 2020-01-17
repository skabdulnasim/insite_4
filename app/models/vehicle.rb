class Vehicle < ActiveRecord::Base
  attr_accessible :contact_no, :license_no, :name, :pincode, :unit_id, :vehicle_image, :pass_key, :vehicle_mode
  
  # => Defining relations
  has_many :stock_transfers
  belongs_to :unit

  # => Model Validations
  validates :name, :presence => true,
                   :length => { :maximum => 50 }
  validates :license_no, :presence => true,
                  :length => { :maximum => 50 }
  validates :unit_id, :presence => true
  validates :contact_no, :presence =>true,
                  :length => { :maximum => 13 }
  validates :pincode, :presence => true,
                  :length => { :maximum => 6 }

  # => Scopes
  scope :unit_vehicles, lambda {|unit_id|where(["unit_id=?", unit_id])}
end
