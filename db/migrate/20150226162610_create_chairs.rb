class CreateChairs < ActiveRecord::Migration
  def change
    create_table :chairs do |t|
      t.integer :table_id
      t.integer :angle

      t.timestamps
    end
  end
end
