json.status @resource.present? ? I18n.t(:ok) : I18n.t(:error)
json.messages do
  json.simple_message @resource.present? ? I18n.t(:success_record_found) : "Resource not found with this Unique no"
  json.internal_message @resource.present? ? I18n.t(:success_record_found) : "Resource not found with this Unique no"
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
elsif @resource.present?  
	json.data do
    json.extract! @resource, :id, :name, :properties, :resource_type_id, :unit_id, :section_id, :resource_image, :resource_state_id, :status, :capacity, :price, :printer_id, :customer_id, :recorded_at, :unique_identity_no
    if @resource.user_resources.present?
    	json.user_id @resource.user_resources.last.user_id
      json.email @resource.user_resources.last.user.email
      json.user_name "#{@resource.user_resources.last.user.profile.firstname}" " #{@resource.user_resources.last.user.profile.lastname}" 
    else
    	json.user_id current_user.id
      json.email current_user.email
      json.user_name "#{current_user.profile.firstname}" " #{current_user.profile.lastname}"
    end	
  end
else
  json.data Hash.new
end