class AddSlotTypeToSlots < ActiveRecord::Migration
  def change
    add_column :slots, :slot_type, :string
  end
end
