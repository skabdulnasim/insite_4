json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_listing_vendor) : I18n.t(:success_listing_vendor)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_listing_vendor)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data @vendors do |vendor|
		json.extract! vendor, :id, :name, :phone, :address, :unit_id, :email, :gst_hash, :latitude, :longitude, :recorded_at
	end
end