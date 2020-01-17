class AddDetailsToUserUnits < ActiveRecord::Migration
  def change
    add_column :user_units, :user_id, :integer
    add_column :user_units, :unit_id, :integer
  end
end
