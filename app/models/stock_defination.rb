class StockDefination < ActiveRecord::Base
  belongs_to :stock
  belongs_to :product_unit, :class_name => "ProductUnit", :foreign_key => :received_product_unit
  attr_accessible :making_cost, :received_product_unit, :sell_price, :wastage, :weight, :sku, :description

  delegate :name, :short_name, :to => :product_unit, allow_nil: true, prefix: true

  def self.save_stock_defination(stock_id,weight,received_product_unit,making_cost,sell_price,wastage,sku,description)
  	_new_defination = StockDefination.new
  	_new_defination[:stock_id] = stock_id
  	_new_defination[:weight] = weight
    _new_defination[:received_product_unit] = received_product_unit
    _new_defination[:making_cost] = making_cost
    _new_defination[:sell_price] = sell_price
    _new_defination[:wastage] = wastage
    _new_defination[:sku] = sku
    _new_defination[:description] = description

  	_new_defination.save
  end

end
