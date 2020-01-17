class AddResourceTargetIdToUserTargetProducts < ActiveRecord::Migration
  def change
    add_column :user_target_products, :resource_target_id, :integer
  end
end
