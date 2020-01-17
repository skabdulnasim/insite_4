class AddDetailsToUnits < ActiveRecord::Migration
  def change
    add_column :units, :unit_name, :string
    add_column :units, :unit_type, :int
  end
end
