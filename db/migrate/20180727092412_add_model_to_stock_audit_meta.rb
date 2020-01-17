class AddModelToStockAuditMeta < ActiveRecord::Migration
  def change
    add_column :stock_audit_meta, :model_no, :string
    add_column :stock_audit_meta, :batch_no, :string
    add_column :stock_audit_meta, :size_id, :integer
    add_column :stock_audit_meta, :color_id, :integer
  end
end
