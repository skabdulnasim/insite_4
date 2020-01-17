class AddExpectedQuantityToSimoOutputProduct < ActiveRecord::Migration
  def change
    add_column :simo_output_products, :expected_quantity, :float
  end
end
