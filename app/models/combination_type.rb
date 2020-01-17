class CombinationType < ActiveRecord::Base
  attr_accessible :name
  has_many :menu_product_combinations
end
