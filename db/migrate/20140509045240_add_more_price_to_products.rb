class AddMorePriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :procured_price, :float
    add_column :products, :mrp, :float
  end
end
