class AddParentToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :parent, :integer
  end
end
