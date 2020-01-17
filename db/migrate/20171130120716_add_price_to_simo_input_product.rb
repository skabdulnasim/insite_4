class AddPriceToSimoInputProduct < ActiveRecord::Migration
  def change
    add_column :simo_input_products, :price, :float
  end
end
