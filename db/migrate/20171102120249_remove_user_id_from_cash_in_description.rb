class RemoveUserIdFromCashInDescription < ActiveRecord::Migration
  def up
    remove_column :cash_in_descriptions, :user_id
    remove_column :cash_in_descriptions, :unit_id
  end

  def down
    add_column :cash_in_descriptions, :unit_id, :integer
    add_column :cash_in_descriptions, :user_id, :integer
  end
end
