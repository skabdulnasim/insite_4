class CreateInspections < ActiveRecord::Migration
  def change
    create_table :inspections do |t|
      t.integer :resource_id
      t.integer :user_id
      t.text :discussion
      t.float :latitude
      t.float :longitude
      t.datetime :recorded_at
      t.string :day

      t.timestamps
    end
  end
end
