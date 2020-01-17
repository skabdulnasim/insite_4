class CreateUserSales < ActiveRecord::Migration
  def change
    create_table :user_sales do |t|
      t.integer :user_id
      t.integer :product_id
      t.integer :resource_id
      t.float :quantity
      t.float :price_with_tax
      t.float :price_without_tax
      t.date :recorded_at

      t.timestamps
    end
  end
end
