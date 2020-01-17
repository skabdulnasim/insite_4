class AddStockAddedToStockAuditMeta < ActiveRecord::Migration
  def change
    add_column :stock_audit_meta, :stock_added, :float
  end
end
