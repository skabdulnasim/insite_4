class CreateReservationGuests < ActiveRecord::Migration
  def change
    create_table :reservation_guests do |t|
      t.string :email
      t.string :mobile_no
      t.string :firstname
      t.string :lastname
      t.text :address

      t.timestamps
    end
  end
end
