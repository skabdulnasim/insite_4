json.status (@error.present? or @validation_errors.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message (@error.present? or @validation_errors.present?) ? I18n.t(:error_try_after_sometime) : I18n.t(:success_preauth_initiate)
  json.internal_message I18n.t(:success_preauth_initiate)
  json.internal_message @validation_errors if @validation_errors.present?
  json.internal_message @error.message if @error.present?
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present? or @validation_errors.present?
  json.data Hash.new
else
  json.data do
    json.extract! @preauth, :id, :amount, :customer_queue_id, :device_id, :unit_id, :created_at, :updated_at, :advance_id, :advance_type
    json.date @preauth.created_at.strftime("%d-%m-%Y")
    json.time @preauth.created_at.strftime("%I:%M %p")
    json.pre_payments @preauth.pre_payments do |pre_payment|
      json.extract! pre_payment, :id, :pre_paymentmode_id, :pre_paymentmode_type, :created_at, :updated_at
      json.transaction_id pre_payment.pre_paymentmode.transaction_id
      json.amount pre_payment.pre_paymentmode.amount
    end
  end  
end