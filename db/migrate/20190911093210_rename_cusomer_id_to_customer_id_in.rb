class RenameCusomerIdToCustomerIdIn < ActiveRecord::Migration
  def up
  	rename_column :customer_product_wishlists, :cusomer_id, :customer_id
  end
end
