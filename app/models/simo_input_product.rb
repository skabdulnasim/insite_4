class SimoInputProduct < ActiveRecord::Base
  attr_accessible :conjugated_id, :product_id, :quantity, :simo_id, :wastage, :price
  has_many :simo_output_products
  belongs_to :simo
  belongs_to :product
  has_many :stocks, as: :stock_transaction
  after_create :debit_stock_from_inventory

  def debit_stock_from_inventory
    issue_stock
  end

  def issue_stock
    if sufficient_in_stock? self.simo.store_id
      cost = Stock.reduce_product_stock(self.simo.store_id,self.product_id,self.quantity,self.simo_id,"simo")
    else
      raise I18n.t(:error_insufficient_stock_for_transfer, items: self.product.name)
    end
  end

  def sufficient_in_stock? primary_store_id
    current_stock = StockUpdate.current_stock(primary_store_id, self.product_id)
    (self.quantity <= current_stock) ? true : false
  end

  def update_wastage
    total_weight = 0
    wastage = 0
    self.simo_output_products.each do |output_product|
      total_weight += output_product.total_weight if output_product.total_weight.present?
    end  
    self.update_attribute(:wastage, (quantity - total_weight).round(2))
  end
  
end
