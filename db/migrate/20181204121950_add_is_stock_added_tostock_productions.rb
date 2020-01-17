class AddIsStockAddedTostockProductions < ActiveRecord::Migration
  def change
  	unless column_exists? :stock_productions, :isStockAdded
    	add_column :stock_productions, :isStockAdded, :integer
    end
  end
end