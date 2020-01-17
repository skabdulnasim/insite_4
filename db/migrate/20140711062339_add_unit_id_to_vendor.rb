class AddUnitIdToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :unit_id, :integer
  end
end
