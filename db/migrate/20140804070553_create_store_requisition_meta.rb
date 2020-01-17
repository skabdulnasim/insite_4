class CreateStoreRequisitionMeta < ActiveRecord::Migration
  def change
    create_table :store_requisition_meta do |t|
      t.integer :requisition_id
      t.integer :product_id
      t.float :product_ammount
      t.integer :product_unit_id

      t.timestamps
    end
  end
end
