class CreateBoxes < ActiveRecord::Migration
  def change
    create_table :boxes do |t|
      t.references :boxing
      t.references :product
      t.references :stock
      t.string :sku

      t.timestamps
    end
    add_index :boxes, :boxing_id
    add_index :boxes, :product_id
    add_index :boxes, :stock_id
  end
end
