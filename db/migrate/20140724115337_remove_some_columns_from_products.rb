class RemoveSomeColumnsFromProducts < ActiveRecord::Migration
  def up
    remove_column :products, :valid_to, :price, :sell_price, :manufacturing_date, :expiry_date, :procured_price, :mrp
  end

  def down
    remove_column :products, :valid_to, :price, :sell_price, :manufacturing_date, :expiry_date, :procured_price, :mrp
  end
end
