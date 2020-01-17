class AddDescToUnits < ActiveRecord::Migration
  def change
    add_column :units, :address, :text
    add_column :units, :landmark, :text
    add_column :units, :city, :string
    add_column :units, :state, :string
    add_column :units, :phpne, :text
  end
end
