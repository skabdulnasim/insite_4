class AddProductBasicUnitToLots < ActiveRecord::Migration
  def change
    add_column :lots, :product_basic_unit, :string
  end
end
