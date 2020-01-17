class AddBasicUnitIdToSimoOutputProduct < ActiveRecord::Migration
  def change
    add_column :simo_output_products, :basic_unit_id, :integer
  end
end
