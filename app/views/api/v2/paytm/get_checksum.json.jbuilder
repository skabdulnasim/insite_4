json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_record_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_record_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Array.new
else
  json.data do
  	json.checksum @checksum_hash
  	json.mid @paytm_keys.mid
  	json.industry_type_id @paytm_keys.industry_type_id
  	json.chanel_id @paytm_keys.channel_id
  	json.website @paytm_keys.website 
	end  
end




