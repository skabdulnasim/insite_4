class AddAttributesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :attributes, :string
  end
end
