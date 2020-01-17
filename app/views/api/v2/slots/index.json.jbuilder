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
  json.data @slots do |slot|
    json.extract! slot, :id, :title, :duration, :status, :max_booking
    json.start_time slot.start_time.strftime("%H:%M") 
    json.end_time slot.end_time.strftime("%H:%M")  
    _total_booking = CustomerQueue.by_date(params[:date]).by_slot(slot.id).is_preauth.sum(:pax)
    _available_pax = slot.max_booking.to_i - _total_booking.to_i
    if _total_booking < slot.max_booking
    	json.availability "available"
      json.flag 1
    	json.available _available_pax
      json.total_booking _total_booking
    else
    	json.availability "unavailable"
      json.falg 0
    	json.available _available_pax
      json.total_booking _total_booking
    end	
  end
end