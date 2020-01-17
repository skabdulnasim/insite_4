json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_listing_resource) : I18n.t(:success_listing_resource)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_listing_resource)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data do
		json.count @date_count
		json.resource_pjp @pjp_date
	end
end