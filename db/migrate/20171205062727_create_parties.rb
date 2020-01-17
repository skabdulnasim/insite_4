class CreateParties < ActiveRecord::Migration
  def change
    create_table :parties do |t|
      t.string :name
      t.string :type
      t.integer :owner_id
      t.timestamp :date_time
      t.string :unique_code

      t.timestamps
    end
  end
end
