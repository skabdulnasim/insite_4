class AddCancellationStatusToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :cancellation_status, :string
  end
end
