class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :unit_id
      t.boolean :is_trashed

      t.timestamps
    end
  end
end
