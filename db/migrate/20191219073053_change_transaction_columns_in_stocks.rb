class ChangeTransactionColumnsInStocks < ActiveRecord::Migration
  def change
  	rename_column :stocks, :transaction_type, :stock_transaction_type
  	rename_column :stocks, :transaction_id, :stock_transaction_id
  end
end