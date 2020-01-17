json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_customer_updated)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_customer_updated)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do
  	json.customer do
    	json.extract! @customer, :id, :email, :mobile_no, :created_at, :updated_at, :gstin, :business_type
    end
    json.profile do
    	json.extract! @customer.customer_profile, :id,:firstname, :lastname, :contact_no, :customer_id, :created_at, :updated_at, :address, :gender, :age, :dob, :anniversary if @customer.customer_profile.present?
    end
  end  
end