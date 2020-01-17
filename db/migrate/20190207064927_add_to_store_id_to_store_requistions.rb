class AddToStoreIdToStoreRequistions < ActiveRecord::Migration
  def change
    add_column :store_requisitions, :to_store_id, :integer
  end
end
