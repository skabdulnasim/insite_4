class AddMinSelectableAndMaxSelectableToAddonsGroups < ActiveRecord::Migration
  def change
    add_column :addons_groups, :min_selectable, :integer
    add_column :addons_groups, :max_selectable, :integer
  end
end
