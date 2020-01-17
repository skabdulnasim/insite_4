class AddLatitudeToStoreRequisitions < ActiveRecord::Migration
  def change
    add_column :store_requisitions, :latitude, :string
    add_column :store_requisitions, :longitude, :string
  end
end
