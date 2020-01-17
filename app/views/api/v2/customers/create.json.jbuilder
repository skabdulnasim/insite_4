json.status (@error.present? or @validation_errors.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  if @status_code.present?
    json.status_code @status_code 
    json.internal_message @status_messge
    json.simple_message @status_messge
  else
    json.status_code (@error.present? or @validation_errors.present?) ? 500 : 200
    json.internal_message (@error.present? or @validation_errors.present?) ? I18n.t(:error_try_after_sometime) : I18n.t(:success_customer_registered)
    json.simple_message @error.present? ? @error.message : I18n.t(:success_customer_registered)
    json.simple_message @validation_errors if @validation_errors.present?
  end
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present? or @validation_errors.present?
  json.data Hash.new
else
  # json.data @customer
  json.data do
    json.success "You have successfully registered"
    json.extract! @customer, :id, :email, :mobile_no, :password, :created_at, :updated_at, :gstin, :business_type
    json.name "#{@customer.customer_profile.firstname}" " #{@customer.customer_profile.lastname}" 
    json.extract! @customer.customer_profile, :firstname, :lastname if @customer.customer_profile.present?
    json.customer do
      json.extract! @customer, :id, :email, :mobile_no, :created_at, :updated_at, :gstin, :business_type
    end
    json.financial_account @customer.financial_account
    json.wallet @customer.wallet
    json.profile do
      json.extract! @customer.customer_profile, :id,:firstname, :lastname, :contact_no, :customer_id, :created_at, :updated_at, :address, :gender, :age, :dob, :anniversary, :pan_no if @customer.customer_profile.present?
      #json.customer_identification_url @customer.customer_profile.customer_identification.url(:original)
    end
    json.address do
      if @customer.addresses.last.present?
        json.extract! @customer.addresses.last, :id, :landmark, :city, :state, :pincode, :contact_no, :latitude, :longitude, :address_type
      end 
    end 
    if @customer.resource.present?
      json.resource do 
        json.extract! @customer.resource, :id, :name, :properties, :resource_type_id, :unit_id, :section_id, :resource_image, :resource_state_id, :user_id, :status, :capacity, :price, :printer_id, :customer_id, :unique_identity_no
        json.bit_id @customer.resource.bits.first.id if @customer.resource.bits.present?
        json.bit_name @customer.resource.bits.first.name if @customer.resource.bits.present?
        if @customer.resource.recorded_at.present?
          json.recorded_at @customer.resource.recorded_at.strftime("%Y-%m-%d %H:%M:%S")
        else
          json.recorded_at @customer.resource.created_at.strftime("%Y-%m-%d %H:%M:%S")  
        end  
        json.resource_type @customer.resource.resource_type.name
        json.customer_name "#{@customer.customer_profile.firstname}" "#{@customer.customer_profile.lastname}" 
        json.latitude @customer.addresses.last.latitude
        json.longitude @customer.addresses.last.longitude
        json.delivery_address @customer.addresses.last.delivery_address
        json.mobile_no @customer.mobile_no
        if @customer.customer_state_id.present?
          json.customer_state_id @customer.customer_state_id
          #json.customer_state @customer.customer_state.name
        else
          json.customer_state_id @customer.customer_state_id
          json.customer_state @customer.customer_state_id 
        end  
        json.user_resources @customer.resource.user_resources do |user_resource|
          json.extract! user_resource, :id, :user_id, :day
          if user_resource.visit_date.present?
            json.visit_date user_resource.visit_date.strftime("%Y-%m-%d")
          end  
        end
      end
    end
    if @customer.customer_queues.present?
      json.customer_queues do
        json.extract! @customer.customer_queues.last, :id, :pax, :trash, :is_reserved, :total_pax, :unit_id, :is_preauth, :customer_id, :customer_queue_state_id, :slot_id
        json.from_date @customer.customer_queues.last.from_date.strftime("%d-%m-%Y, %I:%M %p")
        json.to_date @customer.customer_queues.last.to_date.strftime("%d-%m-%Y, %I:%M %p")
        json.currency currency
        json.preauth @preauth
        if @customer.customer_queues.last.customer_queue_state.present?
          json.customer_queue_state do
            json.extract! @customer.customer_queues.last.customer_queue_state, :id, :name, :color_code
          end
        end  
      end
    end  
  end  
end