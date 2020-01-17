class CreatePackageUnitProducts < ActiveRecord::Migration
  def change
    create_table :package_unit_products do |t|
      t.integer :package_unit_id
      t.integer :product_id
      t.float :quantity

      t.timestamps
    end
  end
end
