class CreateCheckInformations < ActiveRecord::Migration
  def change
    create_table :check_informations do |t|
      t.integer :reservation_id
      t.datetime :check_in_datetime
      t.datetime :check_out_datetime
      t.string :status

      t.timestamps
    end
  end
end
