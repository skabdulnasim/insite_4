class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.string :email
      t.string :mobile_no
      t.integer :party_id
      t.string :party_code

      t.timestamps
    end
  end
end
