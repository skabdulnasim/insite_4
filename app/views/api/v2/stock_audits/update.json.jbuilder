json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_updating_audit) : I18n.t(:success_updating_audit)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_updating_audit)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Hash.new
else
	json.data @stock_audit
end