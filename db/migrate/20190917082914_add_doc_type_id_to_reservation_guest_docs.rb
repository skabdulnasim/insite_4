class AddDocTypeIdToReservationGuestDocs < ActiveRecord::Migration
  def change
    add_column :reservation_guest_docs, :doc_type_id, :integer
  end
end
