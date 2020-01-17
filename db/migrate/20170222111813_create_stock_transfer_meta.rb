class CreateStockTransferMeta < ActiveRecord::Migration
  def change
    create_table :stock_transfer_meta do |t|
      t.belongs_to :stock_transfer
      t.belongs_to :product
      t.float :quantity_transfered
      t.float :quantity_received
      t.float :price_without_tax
      t.belongs_to :tax_group
      t.float :tax_amount
      t.float :price_with_tax
      t.boolean :is_stock_debited, default: false
      t.boolean :is_transferable, default: true

      t.timestamps
    end
    add_index :stock_transfer_meta, :stock_transfer_id
    add_index :stock_transfer_meta, :product_id
    add_index :stock_transfer_meta, :tax_group_id
  end
end
