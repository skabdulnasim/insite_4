class AddVendorIdToStockPurchasePayment < ActiveRecord::Migration
  def change
    add_column :stock_purchase_payments, :vendor_id, :integer
  end
end
