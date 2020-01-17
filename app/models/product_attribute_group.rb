class ProductAttributeGroup < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list
  
  attr_accessible :deleted_at, :is_system_entity, :name, :position
  
  belongs_to :product_attribute_set
  has_and_belongs_to_many :product_attribute_keys

  default_scope { order('position') } 
end
