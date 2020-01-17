class ProductTag < ActiveRecord::Base
  attr_accessible :product_id, :status, :tag_id
  #model validation
  #validates :product_id,  :presence => true
  validates :tag_id,  :presence => true
  #Modle association
  belongs_to :product
  belongs_to :tag
end
