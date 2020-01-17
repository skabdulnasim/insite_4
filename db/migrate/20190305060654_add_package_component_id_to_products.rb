class AddPackageComponentIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :package_component_id, :integer
  end
end
