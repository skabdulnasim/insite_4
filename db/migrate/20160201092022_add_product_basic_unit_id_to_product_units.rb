class AddProductBasicUnitIdToProductUnits < ActiveRecord::Migration
  def change
    add_column :product_units, :product_basic_unit_id, :integer
    ProductUnit.where('basic_inventory_unit=?', 'Kg').update_all(product_basic_unit_id: 1)
    ProductUnit.where('basic_inventory_unit=?', 'lt').update_all(product_basic_unit_id: 2)
    ProductUnit.where('basic_inventory_unit=?', 'Pc').update_all(product_basic_unit_id: 3)
  end
end
