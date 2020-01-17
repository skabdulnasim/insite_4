class CreateBoxItems < ActiveRecord::Migration
  def change
    create_table :box_items do |t|
      t.references :box
      t.references :product
      t.references :stock
      t.string :sku

      t.timestamps
    end
    add_index :box_items, :box_id
    add_index :box_items, :product_id
    add_index :box_items, :stock_id
  end
end
