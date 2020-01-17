class AddStoreIdToBoxings < ActiveRecord::Migration
  def change
    add_column :boxings, :store_id, :integer
  end
end
