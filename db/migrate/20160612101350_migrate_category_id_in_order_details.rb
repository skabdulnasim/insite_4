class MigrateCategoryIdInOrderDetails < ActiveRecord::Migration
  def up
  	orderdetails = OrderDetail.select("DISTINCT menu_product_id")
  	orderdetails.each do |orderdetail|
  		menuproduct = MenuProduct.find(orderdetail.menu_product_id).menu_category_id if MenuProduct.exists?(orderdetail.menu_product_id)
  		OrderDetail.where(:menu_product_id => orderdetail.menu_product_id).update_all(:menu_product_category_id => menuproduct)
  	end	
  end

  def down
  end
end
