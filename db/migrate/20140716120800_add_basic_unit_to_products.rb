class AddBasicUnitToProducts < ActiveRecord::Migration
  def change
    add_column :products, :basic_unit, :string
  end
end
