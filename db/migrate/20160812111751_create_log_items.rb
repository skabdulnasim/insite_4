class CreateLogItems < ActiveRecord::Migration
  def change
    create_table :log_items do |t|
      t.integer :log_id
      t.integer :store_id
      t.integer :from_store_id
      t.integer :store_requisition_id
      t.integer :product_id
      t.integer :product_ammount
      t.string  :status
      t.timestamps
    end
  end
end
