class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.string :title
      t.time :start_time
      t.time :end_time
      t.integer :duration

      t.timestamps
    end
  end
end
