json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
	if @vehicle_disabled.present?
		json.simple_message @vehicle_disabled
	else	
	  json.simple_message @error.present? ? I18n.t(:error_listing_vehicle) : I18n.t(:success_listing_vehicle)
	  json.internal_message @error.present? ? @error.message : I18n.t(:success_listing_vehicle)
	  json.error_code @log[:log_serial] if @error.present? and @log.present?
	  json.error_url @log[:log_url] if @error.present? and @log.present?
	end  
end
if @error.present?
	json.data Array.new
else
	json.data @vehicles do |vehicle|
		json.extract! vehicle, :id, :name, :contact_no, :license_no, :pass_key, :pincode, :vehicle_mode
	end
end