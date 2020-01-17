class AddColumnsToStocks < ActiveRecord::Migration
  def up
  	add_column :stocks, :transaction_id, :integer
  	add_column :stocks, :transaction_type, :string
  	add_column :stocks, :stock_credit, :float
  	add_column :stocks, :stock_debit, :float
  	remove_column :stocks, :quantity
  end
end
