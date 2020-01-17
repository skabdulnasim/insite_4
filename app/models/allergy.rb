class Allergy < ActiveRecord::Base
  attr_accessible :name
  belongs_to :product
  has_many   :allergy_products
  has_many   :products, :through => :allergy_products
end
