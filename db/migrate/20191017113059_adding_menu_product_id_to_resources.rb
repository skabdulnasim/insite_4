class AddingMenuProductIdToResources < ActiveRecord::Migration
  def change
  	unless column_exists? :resources, :menu_product_id
  		add_column :resources, :menu_product_id, :integer
  	end	
  end
end