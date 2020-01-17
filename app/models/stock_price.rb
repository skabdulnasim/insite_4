class StockPrice < ActiveRecord::Base
  attr_accessible :additional_cost, :landing_price, :mrp, :product_id, :stock_id, :total_price, :total_price_without_tax, :total_tax, :addon_cost_remarks, :discount_price, :sales_percentage, :sell_price_with_tax, :purchase_cost, :margin_on_mrp, :volume_discount, :scheme_discount, :scheme_discount_by_amount, :discount_on_mrp
  ### =>  Model Relations
  belongs_to :stock

  ### => Model Validations
  validates :product_id,  :presence => true   
  validates :stock_id,    :presence => true   
  validates :total_price, :presence => true

  ### => Model callback
  after_create :update_stock

  
  def self.add_stock_price(stock_id,landing_price,mrp,product_id,price_wot,_product_tax,additional_cost,total_price,addon_cost_remarks,discount_price,sales_percentage,sell_price_with_tax='',margin_on_mrp='',purchase_cost='',volume_discount='',scheme_discount='',scheme_discount_by_amount='',discount_on_mrp='')
    StockPrice.create(:stock_id=>stock_id,
                      :landing_price=>landing_price, 
                      :mrp=>mrp, 
                      :product_id=>product_id, 
                      :discount_price=>discount_price,
                      :total_price_without_tax=>price_wot,
                      :addon_cost_remarks=>addon_cost_remarks, 
                      :total_tax=>_product_tax, 
                      :additional_cost=>additional_cost,
                      :total_price=>total_price,
                      :sales_percentage=>sales_percentage,
                      :sell_price_with_tax=>sell_price_with_tax,
                      :margin_on_mrp=>margin_on_mrp,
                      :purchase_cost=>purchase_cost,
                      :volume_discount=>volume_discount,
                      :scheme_discount=>scheme_discount,
                      :scheme_discount_by_amount=>scheme_discount_by_amount,
                      :discount_on_mrp => discount_on_mrp)
  end

  def update_stock
    self.stock.update_attributes(:mrp => self.mrp, :landing_price => self.landing_price)
  end

end
