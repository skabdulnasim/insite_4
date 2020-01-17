class AddColumnsForQrCodeShortcuts < ActiveRecord::Migration
  def change
    add_column :categories, :code, :string
    add_column :colors, :code, :string
    add_column :sizes, :code, :string
    add_column :vendors, :code, :string
    add_column :vendors, :vendor_type, :string
    add_column :products, :brand_code, :string
    add_column :products, :p_code, :string
    add_column :stocks, :p_gender, :string
  end
end