json.extract! check_information, :id, :check_in_datetime, :check_out_datetime, :status

json.reservation do
  json.partial! 'api/v2/reservations/reservation', reservation: check_information.reservation
end
if check_information.reservation_guests.present?
	json.reservation_guests check_information.reservation_guests, partial: 'api/v2/check_informations/reservation_guest', as: :reservation_guest
else
	json.reservation_guests []
end