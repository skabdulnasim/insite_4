class AddStoreIdToLots < ActiveRecord::Migration
  def change
    add_column :lots, :store_id, :integer
  end
end
