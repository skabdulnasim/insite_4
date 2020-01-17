class CreateResourceTargets < ActiveRecord::Migration
  def change
    create_table :resource_targets do |t|
      t.integer :user_target_id
      t.integer :target_by
      t.integer :resource_id
      t.float :target_amount

      t.timestamps
    end
  end
end
