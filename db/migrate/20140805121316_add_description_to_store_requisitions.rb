class AddDescriptionToStoreRequisitions < ActiveRecord::Migration
  def change
    add_column :store_requisitions, :description, :text
  end
end
