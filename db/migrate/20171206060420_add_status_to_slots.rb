class AddStatusToSlots < ActiveRecord::Migration
  def change
    add_column :slots, :status, :string
  end
end
