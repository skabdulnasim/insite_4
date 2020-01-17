class AddStatusPositionAngleToTable < ActiveRecord::Migration
  def change
    add_column :tables, :status, :integer
    add_column :tables, :angle, :integer
    add_column :tables, :x_position, :integer
    add_column :tables, :y_position, :integer
  end
end
