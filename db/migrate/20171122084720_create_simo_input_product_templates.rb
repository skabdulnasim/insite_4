class CreateSimoInputProductTemplates < ActiveRecord::Migration
  def change
    create_table :simo_input_product_templates do |t|
      t.integer :input_product_id
      t.integer :output_product_id

      t.timestamps
    end
  end
end
