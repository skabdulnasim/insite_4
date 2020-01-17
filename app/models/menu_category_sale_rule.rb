class MenuCategorySaleRule < ActiveRecord::Base
  attr_accessible :menu_category_id, :sale_rule_id
  #Model validation
  validates :menu_category_id, :presence => true
	validates :sale_rule_id,  :presence => true
	#Model association
	belongs_to :menu_category
	belongs_to :sale_rule
end
