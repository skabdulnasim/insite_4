class LotSaleRule < ActiveRecord::Base
  attr_accessible :lot_id, :sale_rule_id
  
  #Model validation
  validates :lot_id, :presence => true
	validates :sale_rule_id,  :presence => true
	#Model association
	belongs_to :lot
	belongs_to :sale_rule
end
