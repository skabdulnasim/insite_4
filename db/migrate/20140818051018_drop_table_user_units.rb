class DropTableUserUnits < ActiveRecord::Migration
  def up
    drop_table :user_units
  end

  def down
  end
end
