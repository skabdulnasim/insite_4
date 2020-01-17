class AddDiscountQuantityToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :discount_quantity, :float
  end
end
