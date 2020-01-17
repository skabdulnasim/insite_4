class AddSectionIdToResourceTypes < ActiveRecord::Migration
  def change
    add_column :resource_types, :section_id, :integer
  end
end
