class AddUserIdToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :user_id, :integer
  end
end
