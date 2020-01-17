class CombinationsRule < ActiveRecord::Base
  attr_accessible :max_qty, :min_qty, :name
  has_many :menu_product_combinations
end
