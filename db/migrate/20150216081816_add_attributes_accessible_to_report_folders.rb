class AddAttributesAccessibleToReportFolders < ActiveRecord::Migration
  def change
    add_column :report_folders, :attributes_accessible, :string
  end
end
