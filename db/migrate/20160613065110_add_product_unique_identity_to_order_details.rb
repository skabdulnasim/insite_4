class AddProductUniqueIdentityToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :product_unique_identity, :string, after: :menu_product_id
  end
end
