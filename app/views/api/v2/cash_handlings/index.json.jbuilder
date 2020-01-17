json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @cash_handlings.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @cash_handlings.count)
  #json.error_code @log[:log_serial] if @error.present? and @log.present?
  #json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  json.data do
    json.count @cash_handlings.count
    json.current_cash @current_cash
    json.currency currency
    json.cash_handlings @cash_handlings, partial: 'api/v2/cash_handlings/cash_handling', as: :cash_handling
  end 
end