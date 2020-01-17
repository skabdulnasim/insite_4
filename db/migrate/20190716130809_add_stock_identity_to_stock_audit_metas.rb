class AddStockIdentityToStockAuditMetas < ActiveRecord::Migration
  def change
    add_column :stock_audit_meta, :stock_identity, :string
  end
end
