class AddColorNameToColorProducts < ActiveRecord::Migration
  def change
    add_column :color_products, :color_name, :string
  end
end
