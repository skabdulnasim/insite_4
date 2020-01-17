class CreateSmartPos < ActiveRecord::Migration
  def change
    create_table :smart_pos do |t|
      t.string :name
      t.integer :user_id
      t.integer :source_unit

      t.timestamps
    end
  end
end
