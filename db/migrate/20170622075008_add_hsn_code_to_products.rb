class AddHsnCodeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :hsn_code, :string
    add_column :products, :conjugated_unit_id, :integer
    add_column :products, :conjugated_unit, :string
  end
end
