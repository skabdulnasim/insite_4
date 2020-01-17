class AddUserIdToCashIn < ActiveRecord::Migration
  def change
    add_column :cash_ins, :user_id, :integer
  end
end
