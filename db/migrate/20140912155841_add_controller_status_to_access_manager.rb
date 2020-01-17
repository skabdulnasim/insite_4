class AddControllerStatusToAccessManager < ActiveRecord::Migration
  def change
    add_column :access_managers, :controller_status, :integer
  end
end
