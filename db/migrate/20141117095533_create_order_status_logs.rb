class CreateOrderStatusLogs < ActiveRecord::Migration
  def change
    create_table :order_status_logs do |t|
      t.integer :unit_id
      t.integer :order_id
      t.integer :order_status_id
      t.string :order_status_name
      t.integer :user_id

      t.timestamps
    end
  end
end
