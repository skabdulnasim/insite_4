class AddPositionToUnittypes < ActiveRecord::Migration
  def change
    add_column :unittypes, :position, :integer
  end
end
