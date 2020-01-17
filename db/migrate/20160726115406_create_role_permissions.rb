class CreateRolePermissions < ActiveRecord::Migration
  def change
    create_table :roles_permissions, id: false do |t|
      t.belongs_to :role
      t.belongs_to :permission
    end
    add_index :roles_permissions, :permission_id
    add_index :roles_permissions, :role_id
  end
end