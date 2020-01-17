json.status (@error.present? or @customer_queue.pax > @available_pax) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message (@error.present? or @customer_queue.pax > @available_pax) ? I18n.t(:error_try_after_sometime) : I18n.t(:pax_avaliable)
  json.internal_message @error.present? ? @error.message : I18n.t(:pax_avaliable)
  if @customer_queue.pax > @available_pax
  	json.internal_message "Pax are not available"
  end
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present? or @customer_queue.pax > @available_pax
  json.data Array.new
else
  json.data do
  	json.availability "available"
    json.available @available_pax
    json.requested_pax @customer_queue.pax
    json.currency currency
  	json.preauth @preauth
	end  
end