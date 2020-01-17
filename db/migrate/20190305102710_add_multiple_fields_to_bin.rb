class AddMultipleFieldsToBin < ActiveRecord::Migration
  def change
  	add_column :bins, :bin_unique_id, :string
    add_column :bins, :warehouse_rack_id, :integer
    add_column :bins, :rack_unique_id, :string
  end
end
