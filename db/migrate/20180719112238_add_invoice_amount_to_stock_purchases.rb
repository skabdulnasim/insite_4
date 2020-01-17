class AddInvoiceAmountToStockPurchases < ActiveRecord::Migration
  def change
  	add_column :stock_purchases, :invoice_amount, :float
  end
end
