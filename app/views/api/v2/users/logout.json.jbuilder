json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? @error.message : I18n.t(:success_user_logout)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_user_logout)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
json.data Hash.new