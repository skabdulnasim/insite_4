class TaxGroupIdToStockTransferInvoiceMeta < ActiveRecord::Migration
  def change
  	add_column :stock_transfer_invoice_meta, :tax_group_id, :integer
  	add_column :stock_transfer_invoice_meta, :tax_amount, :float
  	add_column :stock_transfer_invoice_meta, :price_with_tax, :float
  	add_index :stock_transfer_invoice_meta, :tax_group_id
  end
end
