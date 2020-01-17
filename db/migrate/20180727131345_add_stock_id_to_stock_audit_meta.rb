class AddStockIdToStockAuditMeta < ActiveRecord::Migration
  def change
    add_column :stock_audit_meta, :stock_id, :integer
  end
end
