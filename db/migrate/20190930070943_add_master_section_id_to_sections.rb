class AddMasterSectionIdToSections < ActiveRecord::Migration
  def change
    add_column :sections, :master_section_id, :integer
  end
end
