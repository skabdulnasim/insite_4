class CreateLotLogs < ActiveRecord::Migration
  def change
    create_table :lot_logs do |t|
      t.integer :lot_id
      t.integer :user_id
      t.float :before_operation_price
      t.float :after_operation_price
      t.float :increase
      t.float :decrease
      t.integer :product_id
      t.integer :menu_product_id

      t.timestamps
    end
  end
end
