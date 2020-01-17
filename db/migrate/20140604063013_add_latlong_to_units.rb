class AddLatlongToUnits < ActiveRecord::Migration
  def change
    add_column :units, :latitude, :text
    add_column :units, :longitude, :text
  end
end
