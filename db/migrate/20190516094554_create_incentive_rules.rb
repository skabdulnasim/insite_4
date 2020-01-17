class CreateIncentiveRules < ActiveRecord::Migration
  def change
    create_table :incentive_rules do |t|
      t.integer :role_id
      t.float :incentive_amount
      t.float :achivement_lower_range
      t.float :achivement_upper_range
      t.string :achivement_range_type

      t.timestamps
    end
  end
end
