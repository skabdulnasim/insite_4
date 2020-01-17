class AddMoreDetailsToStoreRequisitions < ActiveRecord::Migration
  def change
    add_column :store_requisitions, :user_id, :integer
    add_column :store_requisitions, :recurring, :integer
  end
end
