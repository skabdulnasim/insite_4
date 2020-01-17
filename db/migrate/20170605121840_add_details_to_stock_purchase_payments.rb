class AddDetailsToStockPurchasePayments < ActiveRecord::Migration
  def change
    add_column :stock_purchase_payments, :details, :string
  end
end
