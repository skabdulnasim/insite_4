class AddItemCodeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :item_code, :string
    add_column :products, :brand_name, :string
    add_column :products, :mfr_name, :string
  end
end
