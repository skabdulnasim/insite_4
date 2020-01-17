class AddStoreIdToOrderDetailsCombos < ActiveRecord::Migration
  def change
    add_column :order_details_combos, :store_id, :integer
  end
end
