class AddToStoreToStoreRequisitions < ActiveRecord::Migration
  def change
    add_column :store_requisitions, :to_store, :integer
  end
end
