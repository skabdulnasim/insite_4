json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_record_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_record_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do
    json.extract! @stock_purchase, :id
    json.payments @stock_purchase.stock_purchase_payments do |payment|
      json.extract! payment, :id, :created_at, :details
      json.payment_amount payment.payment_amount.to_f.round(2)
      json.payment_mode payment.payment_mode.humanize
      json.payment_date payment.payment_date
    end
  end
end