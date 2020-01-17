class AddMenuProductCategoryIdToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :menu_product_category_id, :integer
    add_index :order_details, :menu_product_category_id
  end
end
