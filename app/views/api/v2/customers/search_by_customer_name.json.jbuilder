json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_record_found)
  json.internal_message @error.present? ? "No record found" : I18n.t(:success_record_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do    
    json.customer @customers do |customer|
      json.extract! customer, :id, :email, :mobile_no, :created_at, :updated_at, :gstin, :business_type
      if customer.customer_profile.present?
        json.name customer.customer_profile.customer_name
      end  
    end
  end
end

