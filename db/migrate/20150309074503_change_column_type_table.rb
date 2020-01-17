class ChangeColumnTypeTable < ActiveRecord::Migration
  def change
    change_column :tables, :reservation_status, :string
  end
end
