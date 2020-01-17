class StockConsumption < ActiveRecord::Base
  attr_accessible :product_id, :stock_debit, :store_id
end
