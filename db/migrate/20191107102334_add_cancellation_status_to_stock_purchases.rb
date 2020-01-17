class AddCancellationStatusToStockPurchases < ActiveRecord::Migration
  def change
    add_column :stock_purchases, :cancellation_status, :string
  end
end
