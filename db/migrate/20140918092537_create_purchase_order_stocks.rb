class CreatePurchaseOrderStocks < ActiveRecord::Migration
  def change
    create_table :purchase_order_stocks do |t|
      t.integer :product_stock
      t.float :po_stock
      t.float :received_stock
      t.float :price
      t.text :status
      t.text :status_log
      t.integer :vendor_id
      t.date :order_date
      t.date :receive_date
      t.float :available_stock
      t.text :consumption_log

      t.timestamps
    end
  end
end
