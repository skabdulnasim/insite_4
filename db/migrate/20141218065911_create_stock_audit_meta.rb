class CreateStockAuditMeta < ActiveRecord::Migration
  def change
    create_table :stock_audit_meta do |t|
      t.integer :stock_audit_id
      t.integer :product_id
      t.float :current_stock
      t.float :counted_stock
      t.float :delta_stock

      t.timestamps
    end
  end
end
