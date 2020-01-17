json.status (@error.present? or !@store_details) ? I18n.t(:error) : I18n.t(:ok)
json.messages do 
	json.simple_message (@error.present? or !@store_details) ? I18n.t(:error_no_records_found) : I18n.t(:success_record_found)
	json.internal_message (@error.present? or !@store_details) ? "No store found with pincode #{params[:pincode]}" : I18n.t(:success_record_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present? or !@store_details
	json.data Hash.new
else
	json.data do
		json.extract! @store_details, :id, :address, :contact_number, :name, :pincode, :store_image, :store_type, :unit_id, :store_priority, :tin_no, :tan_no
	end
end