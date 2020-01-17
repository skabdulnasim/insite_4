class AddAttachmentToStockPurchases < ActiveRecord::Migration
  def up
    add_column :stock_purchases, :attachment, :string
    add_column :stocks, :expiry_date, :date
    remove_column :stocks, :stock_transaction_id
    remove_column :stocks, :stock_status
  end
end
