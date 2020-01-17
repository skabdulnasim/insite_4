json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @promotions.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @promotions.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  json.data @promotions do |promotion|
    json.extract! promotion, :id, :promo_code, :promo_type, :promo_value, :status, :description, :valid_from, :valid_till, :created_at, :promo_user, :count, :bill_amount, :max_discount, :image
  end
end