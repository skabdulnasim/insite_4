class CreateAccessManagers < ActiveRecord::Migration
  def change
    create_table :access_managers do |t|
      t.text :controller_name
      t.text :controller_alias
      t.text :controller_actions

      t.timestamps
    end
  end
end
