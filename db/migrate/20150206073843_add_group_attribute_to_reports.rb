class AddGroupAttributeToReports < ActiveRecord::Migration
  def change
    add_column :reports, :group_attribute, :string
  end
end
