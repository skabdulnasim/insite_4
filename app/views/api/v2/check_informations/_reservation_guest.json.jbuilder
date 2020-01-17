json.extract! reservation_guest, :id, :address, :email, :firstname, :lastname, :mobile_no

json.reservation_guest_docs reservation_guest.reservation_guest_docs, partial: 'api/v2/check_informations/reservation_guest_doc', as: :reservation_guest_doc