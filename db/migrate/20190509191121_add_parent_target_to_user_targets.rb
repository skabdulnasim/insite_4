class AddParentTargetToUserTargets < ActiveRecord::Migration
  def change
    add_column :user_targets, :parent_target, :integer
  end
end
