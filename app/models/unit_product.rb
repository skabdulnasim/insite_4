class UnitProduct < ActiveRecord::Base
  attr_accessible :product_id, :input_tax_group_id, :unit_id
  
  #active record associations
  belongs_to :product
  belongs_to :unit
  belongs_to :tax_group, :class_name => "TaxGroup", :foreign_key => "input_tax_group_id"
  has_many :lots
  #active record callbacks 
  after_update :update_lot_tax_group
  
  #active record scopes
  scope :by_product, lambda { |product_id| where(["product_id=?", product_id])  }
  scope :by_unit, lambda { |unit_id| where(["unit_id=?", unit_id])  }
  
  def update_lot_tax_group
  	puts "updating lot in unit_product"
  	self.lots.each do |lot|
  		lot.update_attribute(:tax_group_id,self.input_tax_group_id)
  		lot.calculate_sell_prices
  	end
  	# self.lots.update_all(tax_group_id: self.input_tax_group_id)
  end
end
