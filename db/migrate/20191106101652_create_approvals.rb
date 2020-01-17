class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.string :approvable_type
      t.integer :approvable_id
      t.integer :role_id
      t.integer :user_id
      t.string :is_approve

      t.timestamps
    end
  end
end
