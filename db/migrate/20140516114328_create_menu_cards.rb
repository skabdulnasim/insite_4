class CreateMenuCards < ActiveRecord::Migration
  def change
    create_table :menu_cards do |t|
      t.string :name
      t.datetime :valid_from
      t.datetime :valid_till
      t.integer :mode

      t.timestamps
    end
  end
end
