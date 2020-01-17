class Attribute < ActiveRecord::Base
  attr_accessible :name
  has_many :term_attributes
  scope :get_attribute_name, lambda {|id|where(["id=?", id])}

  has_many :product_attributes
  has_many :products, through: :product_attributes
end
