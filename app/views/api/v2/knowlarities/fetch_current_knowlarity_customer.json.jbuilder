json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_record_found)
  json.internal_message @error.present? ? "No record found" : I18n.t(:success_record_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  if @customer_number.present?
    json.data do
      json.contact_no @customer_number
    end
  else
    json.data Hash.new
  end
else
  json.data do    
    json.extract! @customer, :id, :email, :mobile_no, :created_at, :updated_at, :gstin, :business_type
    json.name "#{@customer.customer_profile.firstname}" " #{@customer.customer_profile.lastname}"
    json.extract! @customer.profile, :firstname, :lastname, :contact_no, :customer_id, :created_at, 
    :updated_at, :address, :gender, :age, :dob, :anniversary ,:pan_no if @customer.profile.present?
    json.profile_id @customer.profile.id if @customer.profile.present?
    json.addresses @customer.addresses do |address|
      json.extract! address, :id, :receiver_first_name, :receiver_last_name, :delivery_address, :landmark, :city, :state, :pincode, :contact_no, :latitude, :longitude, :address_type
    end
  end
end