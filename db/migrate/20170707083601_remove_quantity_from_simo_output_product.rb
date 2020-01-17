class RemoveQuantityFromSimoOutputProduct < ActiveRecord::Migration
  def up
    remove_column :simo_output_products, :quantity
  end

  def down
    add_column :simo_output_products, :quantity, :float
  end
end
