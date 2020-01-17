json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_loyalty_card_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_loyalty_card_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do 
    json.extract! @loyalty_card, :id, :card_no, :card_serial, :name_on_card, :card_class, :customer_id, :status, :total_valid_point, :total_valid_amount
  end
end