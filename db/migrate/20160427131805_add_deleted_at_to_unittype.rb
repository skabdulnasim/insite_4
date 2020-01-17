class AddDeletedAtToUnittype < ActiveRecord::Migration
  def change
    add_column :unittypes, :deleted_at, :datetime
  end
end
