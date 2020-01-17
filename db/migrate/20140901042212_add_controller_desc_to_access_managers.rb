class AddControllerDescToAccessManagers < ActiveRecord::Migration
  def change
    add_column :access_managers, :controller_desc, :text
  end
end
