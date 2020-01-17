class CostCategory < ActiveRecord::Base
  attr_accessible :description, :name

  has_many :menu_products
  
end
