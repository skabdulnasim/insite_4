class CreateVisitingHistories < ActiveRecord::Migration
  def change
    create_table :visiting_histories do |t|
      t.integer :user_id
      t.string :day
      t.datetime :recorded_at
      t.integer :resource_id
      t.time :in_time
      t.time :out_time
      t.string :latitude
      t.string :longitude
      t.string :visiting_type
      t.string :visting_reason

      t.timestamps
    end
  end
end
