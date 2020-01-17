class AddCapabilitiesToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :capabilities, :text
  end
end
