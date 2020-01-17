class AddFreeQuantityToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :free_quantity, :float
  end
end
