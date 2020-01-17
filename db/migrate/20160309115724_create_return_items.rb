class CreateReturnItems < ActiveRecord::Migration
  def change
    create_table :return_items do |t|
      t.integer :bill_id
      t.integer :unit_id
      t.integer :order_detail_id
      t.integer :product_id
      t.float :price
      t.integer :quantity
      t.text :remarks
      t.boolean :added_to_stock, default: false
      t.integer :store_id

      t.timestamps
    end
  end
end
