json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_listing_slot) : I18n.t(:success_listing_slot)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_listing_slot)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Array.new
else
  json.data do
  	json.avaliable_slot do
	  	if @reservations.blank?
	  		slot = Slot.find(@slot_id)
	  		json.start_time slot.start_time.strftime("%H:%M:%S")
	  		json.end_time slot.end_time.strftime("%H:%M:%S")
	  		json.start_time slot.start_time.strftime("%H:%M:%S")
	  		json.next_start_time slot.start_time.strftime("%H:%M:%S")
	  		json.next_end_time (slot.start_time + slot.duration*60).strftime("%H:%M:%S")
	  		json.duration slot.duration
	  	else
	  		res = @reservations.first
	  		json.start_time res.start_time.strftime("%H:%M:%S")
	  		json.end_time res.end_time.strftime("%H:%M:%S")
	  		json.start_time res.start_time.strftime("%H:%M:%S")
	  		json.next_start_time res.end_time.strftime("%H:%M:%S")
	  		json.next_end_time (res.end_time + res.slot.duration*60).strftime("%H:%M:%S")
	  		json.duration res.slot.duration
	  	end 
	  end	
	end  
end