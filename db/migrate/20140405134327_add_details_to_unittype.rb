class AddDetailsToUnittype < ActiveRecord::Migration
  def change
    add_column :unittypes, :unit_type_name, :string
    add_column :unittypes, :unit_type_priority, :int
  end
end
