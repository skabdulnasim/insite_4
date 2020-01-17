class AddTotalWeightToSimoOutputProducts < ActiveRecord::Migration
  def change
    add_column :simo_output_products, :total_weight, :float
  end
end