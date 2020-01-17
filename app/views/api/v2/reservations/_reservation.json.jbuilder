json.extract! reservation, :id, :reservation_date, :customer_id, :resource_id, :created_at, :pax, :trash, :confirm_reservation_cancel, :customer_queue_id, :user_id, :device_id
if reservation.trash == 0
  json.status "Allocated"
else
  json.status "Cancel"  
end
json.check_information reservation.check_information
json.source reservation.source.humanize
if reservation.start_date.present?
  json.start_time reservation.start_date.strftime("%d-%m-%Y, %I:%M %p")
  json.end_time reservation.end_date.strftime("%d-%m-%Y, %I:%M %p")
else
  json.start_time reservation.start_time.strftime("%I:%M %p")
  json.end_time reservation.end_time.strftime("%I:%M %p") 
end  
if reservation.bill.present?
  json.bill_status reservation.bill.status
  json.payment_status reservation.bill.status
  json.bill_date reservation.bill.created_at
  json.bill_id reservation.bill_id
end  
#Adding customer info

json.customer do
  json.extract! reservation.customer, :id, :email, :mobile_no, :customer_unique_id
  json.name "#{reservation.customer.customer_profile.firstname}" " #{reservation.customer.customer_profile.lastname}"  
  json.custmer_profile do
    json.extract! reservation.customer.customer_profile, :id, :firstname, :lastname, :address, :age, :anniversary, :contact_no, :dob, :gender
  end
  if reservation.customer.addresses.present?
    json.addresses reservation.customer.addresses do |address|
      json.extract! address, :id, :landmark, :city, :state, :pincode, :contact_no, :latitude, :longitude
    end   
  end  
end

json.unit do
  json.extract! reservation.unit, :id, :unit_name, :address, :landmark, :locality, :pincode, :city, :state, :country, :time_zone, :latitude, :longitude, :phone
  json.section do 
    json.extract! Section.unit_sections(reservation.unit.id).dinein_section.first, :id , :name, :section_type
    json.dinein_menu_card do
      json.extract! Section.unit_sections(reservation.unit.id).dinein_section.first.menu_cards.active.first, :id, :name, :master_menu_id, :scope, :updated_at
    end
  end
end

# Adding resource info
# json.resource do
#   json.extract! reservation.resource, :id, :name
#   json.resource_type reservation.resource.resource_type.name
#   json.resource_properties reservation.resource.properties
#   json.resource_image reservation.resource.resource_image
#   json.capacity reservation.resource.capacity
#   json.price reservation.resource.price
#   json.currency currency
#   if reservation.resource.menu_card.present?
#     json.menu_card do
#       json.partial! 'api/v2/reservations/menu_card', menu_card: reservation.resource.menu_card
#     end  
#   else
#     _blank = {}
#     json.menu_card _blank  
#   end
# end

# json.resources reservation.reservation_details do |reservation_detail|
#   json.extract! reservation_detail.resource, :id, :name
#   json.resource_type reservation_detail.resource.resource_type.name
#   json.resource_properties reservation_detail.resource.properties
#   json.resource_image reservation_detail.resource.resource_image
#   json.capacity reservation_detail.resource.capacity
#   json.price reservation_detail.resource.price
#   json.currency currency
#   if reservation_detail.resource.menu_card.present?
#     json.menu_card do
#       json.partial! 'api/v2/reservations/menu_card', menu_card: reservation_detail.resource.menu_card
#     end  
#   else
#     _blank = {}
#     json.menu_card _blank  
#   end
# end

json.resources reservation.reservation_details.joins(:resource).merge(Resource.get_root_resources) do |reservation_detail|
  json.extract! reservation_detail.resource, :id, :name
  json.extract! reservation_detail.resource, :id, :name
  json.resource_type reservation_detail.resource.resource_type.name
  json.resource_properties reservation_detail.resource.properties
  json.resource_image reservation_detail.resource.resource_image
  json.capacity reservation_detail.resource.capacity
  json.price reservation_detail.resource.price
  json.currency currency
  json.is_parent reservation_detail.is_parent
  if reservation_detail.resource.menu_card.present?
    json.menu_card do
      json.partial! 'api/v2/reservations/menu_card', menu_card: reservation_detail.resource.menu_card
    end  
  else
    _blank = {}
    json.menu_card _blank  
  end
  json.child_resources reservation.reservation_details.set_resource_ids(Resource.by_parent_resource(reservation_detail.resource_id).pluck(:id)) do |child_resource_rd|
    json.extract! child_resource_rd.resource, :id, :name
    json.resource_type child_resource_rd.resource.resource_type.name
    json.resource_properties child_resource_rd.resource.properties
    json.resource_image child_resource_rd.resource.resource_image
    json.capacity child_resource_rd.resource.capacity
    json.price child_resource_rd.resource.price
    json.currency currency
    json.is_parent child_resource_rd.is_parent
  end
end

# Adding bill details
if reservation.bill.present?
  json.bill do
    json.extract! reservation.bill, :id, :bill_amount, :status, :grand_total
    json.currency currency
  end
end