class AddPriceToSimoInputProducts < ActiveRecord::Migration
  def change
    add_column :simo_input_products, :wastage, :float
  end
end
