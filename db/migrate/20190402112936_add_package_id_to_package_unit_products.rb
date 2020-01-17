class AddPackageIdToPackageUnitProducts < ActiveRecord::Migration
  def change
    add_column :package_unit_products, :package_id, :integer
  end
end
