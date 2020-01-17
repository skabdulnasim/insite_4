class MenuProductSaleRule < ActiveRecord::Base
  attr_accessible :menu_product_id, :sale_rule_id, :menu_card_id
  #Model validation
  validates :menu_product_id, :presence => true
	validates :sale_rule_id,  :presence => true
	#Model association
	belongs_to :menu_product
	belongs_to :sale_rule

	#Model Scopes
	scope :by_menu_card,      lambda {|menu_card_id|where(["menu_card_id=?", menu_card_id])}
	scope :by_menu_product,   lambda {|menu_product_id| where (["menu_product_id = ?", menu_product_id])}
end