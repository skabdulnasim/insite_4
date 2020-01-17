class AddTargetTypeDurationToResourceTargets < ActiveRecord::Migration
  def change
    add_column :resource_targets, :target_type, :string
    add_column :resource_targets, :duration, :string
  end
end
