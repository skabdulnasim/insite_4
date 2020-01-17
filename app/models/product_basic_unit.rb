class ProductBasicUnit < ActiveRecord::Base
  attr_accessible :name, :short_name
  
  validates :short_name,  :presence => true,
                          :uniqueness => true
  validates :name,  :presence => true

  # Model Relations
  has_many :product_units
end
