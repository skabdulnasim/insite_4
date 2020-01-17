class Package < ActiveRecord::Base
  attr_accessible :customer_id, :name, :production_status

  #Model Relations
  belongs_to :customer
  has_many :package_units, :dependent => :destroy
end