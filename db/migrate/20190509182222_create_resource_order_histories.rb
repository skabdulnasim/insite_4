class CreateResourceOrderHistories < ActiveRecord::Migration
  def change
    create_table :resource_order_histories do |t|
      t.integer :resource_id
      t.integer :user_id
      t.integer :unit_id
      t.datetime :recorded_at
      t.string :latitude
      t.string :longitude
      t.string :device_id
      t.timestamps
    end
  end
end
