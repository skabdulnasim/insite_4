class AddStoreIdToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :store_id, :integer
    add_column :menu_products, :default, :integer
  end
end
