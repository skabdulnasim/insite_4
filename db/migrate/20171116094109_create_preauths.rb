class CreatePreauths < ActiveRecord::Migration
  def change
    create_table :preauths do |t|
      t.integer :user_id
      t.integer :unit_id
      t.integer :customer_queue_id
      t.integer :device_id
      t.float :amount

      t.timestamps
    end
  end
end
