class AddStoreIdToSimo < ActiveRecord::Migration
  def change
    add_column :simos, :store_id, :integer
  end
end
