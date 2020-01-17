class AddSellPriceWithTaxToStockAuditMeta < ActiveRecord::Migration
  def change
    add_column :stock_audit_meta, :sell_price_with_tax, :float
  end
end
