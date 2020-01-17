class AddSectionIdToAddonsGroups < ActiveRecord::Migration
  def change
    add_column :addons_groups, :section_id, :integer
  end
end
