class CreateUserWorkStatuses < ActiveRecord::Migration
  def change
    create_table :user_work_statuses do |t|
      t.integer :user_id
      t.string :work_status
      t.text :remarks
      t.string :latitude
      t.string :longitude
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
