class CreateProductTransactionUnits < ActiveRecord::Migration
  def change
    create_table :product_transaction_units do |t|
      t.references :product
      t.string :transaction_type
      t.references :product_unit
      t.string :product_unit_name
      t.float :basic_unit_multiplier
      t.references :basic_unit

      t.timestamps
    end
  end
end
