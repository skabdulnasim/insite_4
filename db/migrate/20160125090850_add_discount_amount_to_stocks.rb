class AddDiscountAmountToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :discount_price, :float
    remove_column :stocks, :discount_quantity
  end
end
