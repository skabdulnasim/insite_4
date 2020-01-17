class CreateStockTaxes < ActiveRecord::Migration
  def change
    create_table :stock_taxes do |t|
      t.integer :stock_id
      t.integer :tax_class_id
      t.string :tax_class_name
      t.float :tax_percentage
      t.float :tax_amount
      t.string :tax_type

      t.timestamps
    end
  end
end
