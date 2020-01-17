class RemoveColumnDocTypeFromReservationGuestDocs < ActiveRecord::Migration
  def up
    remove_column :reservation_guest_docs, :doc_type
  end
end