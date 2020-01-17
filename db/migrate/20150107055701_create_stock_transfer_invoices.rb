class CreateStockTransferInvoices < ActiveRecord::Migration
  def change
    create_table :stock_transfer_invoices do |t|
      t.integer :stock_transfer_id
      t.float :price

      t.timestamps
    end
  end
end
