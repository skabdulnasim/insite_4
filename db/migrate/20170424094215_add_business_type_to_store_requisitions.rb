class AddBusinessTypeToStoreRequisitions < ActiveRecord::Migration
  def change
    add_column :store_requisitions, :business_type, :string
  end
end
