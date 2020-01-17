class AddParentToProducts < ActiveRecord::Migration
  def change
    add_column :products, :parent, :integer
  end
end
