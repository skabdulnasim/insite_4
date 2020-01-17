class AddLocalNameToProducts < ActiveRecord::Migration
  def change
    add_column :products, :local_name, :string
  end
end
