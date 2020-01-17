class AddUnitIdToSlots < ActiveRecord::Migration
  def change
    unless column_exists? :slots, :unit_id
      add_column :slots, :unit_id, :integer
    end
  end
end
