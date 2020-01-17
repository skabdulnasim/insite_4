class AddIndexValidationToUserTargets < ActiveRecord::Migration
  def change
  	add_index :user_targets, [:child_user_id, :from_date], unique: true
  end
end
