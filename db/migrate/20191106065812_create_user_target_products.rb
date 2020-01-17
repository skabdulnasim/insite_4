class CreateUserTargetProducts < ActiveRecord::Migration
  def change
    create_table :user_target_products do |t|
      t.integer :user_target_id
      t.integer :product_id
      t.float :target_quantity

      t.timestamps
    end
  end
end
