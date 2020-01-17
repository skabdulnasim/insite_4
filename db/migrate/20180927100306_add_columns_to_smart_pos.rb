class AddColumnsToSmartPos < ActiveRecord::Migration
  def change
    add_column :smart_pos, :store_id, :integer
    add_column :smart_pos, :valid_from, :datetime
    add_column :smart_pos, :valid_till, :datetime
    add_column :smart_pos, :vendor_id, :integer
  end
end
