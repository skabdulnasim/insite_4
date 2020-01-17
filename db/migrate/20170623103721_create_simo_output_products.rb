class CreateSimoOutputProducts < ActiveRecord::Migration
  def change
    create_table :simo_output_products do |t|
      t.integer :product_id
      t.float :quantity
      t.integer :simo_id
      t.integer :basic_id
      t.integer :simo_input_product_id

      t.timestamps
    end
  end
end
