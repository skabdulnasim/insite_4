class AddSkuToPackageUnitProducts < ActiveRecord::Migration
  def change
    add_column :package_unit_products, :sku, :string
  end
end
