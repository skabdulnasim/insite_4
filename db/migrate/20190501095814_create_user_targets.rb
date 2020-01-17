class CreateUserTargets < ActiveRecord::Migration
  def change
    create_table :user_targets do |t|
      t.integer :parent_user_id
      t.integer :child_user_id
      t.string :duration
      t.date :from_date
      t.date :to_date
      t.string :target_type
      t.float :target_amount
      t.integer :is_approved
      t.text :rejection_reason

      t.timestamps
    end
  end
end
