class AddPaymentStatusToStockPurchases < ActiveRecord::Migration
  def change
    add_column :stock_purchases, :payment_status, :string
  end
end
