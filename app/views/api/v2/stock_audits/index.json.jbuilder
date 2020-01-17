json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_listing_audit) : I18n.t(:success_listing_audit)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_listing_audit)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data do
		json.audit_data @stock_audits do |stock_audit|
			json.partial! 'api/v2/stock_audits/audit', stock_audit: stock_audit
		end
		json.user_data @user if params[:user_id].present?
	end
end