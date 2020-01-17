class AddDetailsToStoreRequisitions < ActiveRecord::Migration
  def change
    add_column :store_requisitions, :name, :string
    add_column :store_requisitions, :type, :string
    add_column :store_requisitions, :valid_from, :datetime
    add_column :store_requisitions, :valid_till, :datetime
    add_column :store_requisitions, :mode, :integer
    add_column :store_requisitions, :store_id, :integer
    add_column :store_requisitions, :unit_id, :integer
  end
end
