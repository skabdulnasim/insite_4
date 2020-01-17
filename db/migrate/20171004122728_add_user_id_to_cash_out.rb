class AddUserIdToCashOut < ActiveRecord::Migration
  def change
    add_column :cash_outs, :user_id, :integer
  end
end
