json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_listing_slot) : I18n.t(:success_read_upi_merchant)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_read_upi_merchant)
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Array.new
else
  json.data @upi_merchant
end