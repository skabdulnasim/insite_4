class CreateResourceProducts < ActiveRecord::Migration
  def change
    create_table :resource_products do |t|
      t.integer :resource_id
      t.integer :product_id

      t.timestamps
    end
  end
end
