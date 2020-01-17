class AddRemarksToStockAuditMeta < ActiveRecord::Migration
  def change
    add_column :stock_audit_meta, :remarks, :text
    add_column :stock_audit_meta, :audit_options, :text
    remove_column :stock_audits, :remarks
  end
end
