class ChangeAttributesAccessibleInReportFolders < ActiveRecord::Migration
  def up
    change_column :report_folders, :attributes_accessible, :text
  end

  def down
    change_column :report_folders, :attributes_accessible, :character
  end
end
