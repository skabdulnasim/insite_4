class CreateStockPurchasePayments < ActiveRecord::Migration
  def change
    create_table :stock_purchase_payments do |t|
      t.float :payment_amount
      t.string :payment_mode
      t.integer :stock_puchase_id

      t.timestamps
    end
  end
end
