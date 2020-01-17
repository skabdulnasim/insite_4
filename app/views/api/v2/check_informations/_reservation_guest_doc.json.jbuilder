json.extract! reservation_guest_doc, :id, :reservation_guest_id, :doc_type_id
json.doc_type_title reservation_guest_doc.doc_type.title
json.doc_file reservation_guest_doc.doc_file

# json.doc_file reservation_guest_doc.doc_file if reservation_guest_doc.doc_file.present?