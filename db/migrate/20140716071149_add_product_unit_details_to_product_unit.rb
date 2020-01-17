class AddProductUnitDetailsToProductUnit < ActiveRecord::Migration
  def change
    add_column :product_units, :multiplier, :float
    add_column :product_units, :basic_inventory_unit, :string
  end
end
