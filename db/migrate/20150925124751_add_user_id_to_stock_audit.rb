class AddUserIdToStockAudit < ActiveRecord::Migration
  def change
    add_column :stock_audits, :audit_done_by, :integer
    add_column :stock_audits, :audit_reviewed_by, :integer
    add_column :stock_audit_meta, :stock_consumed, :float
    add_column :stock_audit_meta, :current_stock_at_review, :float
  end
end
