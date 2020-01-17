class AddDeletedAtToUnits < ActiveRecord::Migration
  def change
    add_column :units, :deleted_at, :datetime
    remove_column :units, :store_creatability
    remove_column :units, :phpne
    remove_column :units, :is_trashed
  end
end
