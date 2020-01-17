class AddTimeZoneToUnits < ActiveRecord::Migration
  def change
    add_column :units, :time_zone, :text
  end
end
