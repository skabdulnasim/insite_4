class AddPaymentDateToStockPurchasePayments < ActiveRecord::Migration
  def change
    add_column :stock_purchase_payments, :payment_date, :date
  end
end
