class ChangeMenuProductIdToMenuCardIdInResources < ActiveRecord::Migration
  def change
  	rename_column :resources, :menu_product_id, :menu_card_id
  end
end
