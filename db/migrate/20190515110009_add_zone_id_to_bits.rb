class AddZoneIdToBits < ActiveRecord::Migration
  def change
    add_column :bits, :zone_id, :integer
  end
end
