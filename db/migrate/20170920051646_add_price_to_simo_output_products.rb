class AddPriceToSimoOutputProducts < ActiveRecord::Migration
  def change
    add_column :simo_output_products, :price, :float
  end
end
