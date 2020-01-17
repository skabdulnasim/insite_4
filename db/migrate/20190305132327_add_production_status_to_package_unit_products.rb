class AddProductionStatusToPackageUnitProducts < ActiveRecord::Migration
  def change
    add_column :package_unit_products, :production_status, :string
  end
end
