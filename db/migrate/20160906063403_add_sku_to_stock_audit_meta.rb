class AddSkuToStockAuditMeta < ActiveRecord::Migration
  def change
    add_column :stock_audit_meta, :sku, :string
  end
end
