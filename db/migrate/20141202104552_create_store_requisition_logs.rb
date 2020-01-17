class CreateStoreRequisitionLogs < ActiveRecord::Migration
  def change
    create_table :store_requisition_logs do |t|
      t.integer :store_id
      t.integer :from_store_id
      t.integer :store_requisition_id
      t.string :status
      t.integer :product_count
      t.integer :sent_product_count

      t.timestamps
    end
  end
end
