class AddIsTrashedToUnits < ActiveRecord::Migration
  def change
    add_column :units, :is_trashed, :boolean, default: false
  end
end
