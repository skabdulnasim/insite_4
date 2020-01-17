json.extract! customer, :id, :email, :mobile_no, :customer_unique_id
json.name "#{customer.customer_profile.firstname}" " #{customer.customer_profile.lastname}" 
json.address do
	if customer.addresses.last.present?
  	json.extract! @customer.addresses.last, :id, :landmark, :city, :state, :pincode, :contact_no, :latitude, :longitude
  end	
end 
json.customer_queues do
  json.extract! @customer.customer_queues.last, :id, :pax, :trash, :is_reserved, :total_pax, :unit_id, :is_preauth, :customer_id, :customer_queue_state_id, :slot_id
  json.from_date @customer.customer_queues.last.from_date.strftime("%d-%m-%Y, %I:%M %p")
  json.to_date @customer.customer_queues.last.to_date.strftime("%d-%m-%Y, %I:%M %p")
  json.currency currency
  json.preauth @preauth
  if @customer.customer_queues.last.customer_queue_state.present?
	  json.customer_queue_state do
	  	json.extract! @customer.customer_queues.last.customer_queue_state, :id, :name, :color_code
	  end
	end  
end
json.unit do
  json.extract! @customer.customer_queues.last.unit, :id, :unit_name, :address, :landmark, :locality, :pincode, :city, :state, :country, :time_zone, :latitude, :longitude, :phone
  json.section do 
    json.extract! Section.unit_sections(@customer.customer_queues.last.unit.id).dinein_section.first, :id , :name, :section_type
    json.dinein_menu_card do
      json.extract! Section.unit_sections(@customer.customer_queues.last.unit.id).dinein_section.first.menu_cards.active.first, :id, :name, :master_menu_id, :scope, :updated_at
    end
  end
end
