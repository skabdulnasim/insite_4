class AddReasonCodeToStockAuditMeta < ActiveRecord::Migration
  def change
    add_column :stock_audit_meta, :reason_code, :string
  end
end
