json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_customer_login)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_customer_login)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  # json.data @response
  json.data do
    json.extract! @response[:success][:customer], :id, :email, :mobile_no
    json.extract! @response[:success][:profile], :firstname, :lastname if @response[:success][:profile].present?
    json.addresses @response[:success][:address] do |address|
      json.extract! address, :id, :receiver_first_name, :receiver_last_name, :delivery_address, :landmark, :city, :state, :pincode, :contact_no, :latitude, :longitude
    end
  end
end