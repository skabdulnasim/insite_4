class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :subject_class
      t.string :action
      t.string :description
      t.belongs_to :permission_group

      t.timestamps
    end
    add_index :permissions, :permission_group_id
  end
end
