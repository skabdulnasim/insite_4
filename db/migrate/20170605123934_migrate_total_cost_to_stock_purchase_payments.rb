class MigrateTotalCostToStockPurchasePayments < ActiveRecord::Migration
  def up
  	@stock_purcahses = StockPurchase.received
  	@stock_purcahses.each do |sp|
  		price = sp.stocks.sum(:price)
  		puts price
  		sp.update_attributes(:total_amount => price,:paid_amount => price, :payment_status => "paid")
  	end 
  end

  def down
  end
end
