class CreateSimoInputProducts < ActiveRecord::Migration
  def change
    create_table :simo_input_products do |t|
      t.integer :product_id
      t.float :quantity
      t.integer :simo_id
      t.integer :conjugated_id

      t.timestamps
    end
  end
end