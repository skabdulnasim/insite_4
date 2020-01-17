class CreateColorProducts < ActiveRecord::Migration
  def change
    create_table :color_products do |t|
      t.integer :color_id
      t.integer :product_id

      t.timestamps
    end
  end
end
