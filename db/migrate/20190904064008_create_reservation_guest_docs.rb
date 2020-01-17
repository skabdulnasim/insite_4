class CreateReservationGuestDocs < ActiveRecord::Migration
  def change
    create_table :reservation_guest_docs do |t|
      t.integer :reservation_guest_id
      t.string :doc_type

      t.timestamps
    end
  end
end
