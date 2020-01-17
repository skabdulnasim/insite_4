class AddInvoiceDateAndInvoiceNoToStockPurchases < ActiveRecord::Migration
  def change
    add_column :stock_purchases, :invoice_date, :date
    add_column :stock_purchases, :invoice_no, :string
  end
end
