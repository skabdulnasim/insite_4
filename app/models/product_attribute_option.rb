class ProductAttributeOption < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list

  attr_accessible :label, :value, :is_default

  belongs_to :product_attribute_key

  validates :label, :presence => true
  validates :value, :presence => true

  default_scope { order('position') } 
  
end
