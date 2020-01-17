class AddActualQuantityToSimoOutputProduct < ActiveRecord::Migration
  def change
    add_column :simo_output_products, :actual_quantity, :float
  end
end
