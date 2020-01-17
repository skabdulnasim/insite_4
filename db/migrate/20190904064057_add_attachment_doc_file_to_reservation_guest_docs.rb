class AddAttachmentDocFileToReservationGuestDocs < ActiveRecord::Migration
  def self.up
    change_table :reservation_guest_docs do |t|
      t.attachment :doc_file
    end
  end

  def self.down
    remove_attachment :reservation_guest_docs, :doc_file
  end
end
