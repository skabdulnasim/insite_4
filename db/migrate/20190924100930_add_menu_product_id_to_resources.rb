class AddMenuProductIdToResources < ActiveRecord::Migration
  def change
    add_column :resources, :menu_product_id, :integer
  end
end
