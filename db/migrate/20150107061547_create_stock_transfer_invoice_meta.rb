class CreateStockTransferInvoiceMeta < ActiveRecord::Migration
  def change
    create_table :stock_transfer_invoice_meta do |t|
      t.integer :stock_transfer_invoice_id
      t.integer :product_id
      t.float :quantity
      t.float :price

      t.timestamps
    end
  end
end
