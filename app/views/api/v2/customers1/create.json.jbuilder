json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_customer_registered)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_customer_registered)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data @response
  json.data do
    json.extract! @response[:customer], :id, :email, :mobile_no, :gstin, :business_type
    json.extract! @response[:profile], :firstname, :lastname if @response[:profile].present?
  end  
end