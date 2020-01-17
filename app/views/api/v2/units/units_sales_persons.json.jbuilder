json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? "Sorry!! Could not find any branches" : "#{@units.count} branches loaded."
  json.internal_message @error.present? ? @error.message : "#{@units.count} units loaded."
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Array.new
else
	json.data(@units) do |unit|
		json.extract! unit, :id, :unit_name, :address, :landmark, :locality, :pincode, :city, :state, :country, :time_zone, :latitude, :longitude, :phone, :unittype_id, :unit_image
		if current_user.role.name == "sale_person"
			users = User.by_id(current_user.id)	
		elsif current_user.role.name == "bill_manager"
			bill_manager_role = Role.find_by_name("bill_manager")
			@roll_arr.push(bill_manager_role.id)
			users = User.set_role(@roll_arr).by_unit(unit.id)	
		elsif current_user.role.name == "owner"
			users = User.set_role(@roll_arr)
			@resources = Resource.active_only
		elsif current_user.role.name == "dc_manager"
			users = User.set_role(@roll_arr)
			@resources = Resource.active_only		
		end
		#users = unit.users
		json.user_profile(users) do |user|
			json.user user
			json.profile user.profile
			json.user_role user.users_role.role.name
			json.resources Resource.active_only.set_user(user.id).uniq do |resource|
				json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :printer_id,:customer_id 
				if resource.customer_id.present?
          customer = Customer.find(resource.customer_id)
          json.customer_name customer.customer_profile.customer_name
          json.latitude customer.addresses.first.latitude
          json.longitude customer.addresses.first.longitude
          json.delivery_address customer.addresses.first.delivery_address
          json.mobile_no customer.mobile_no
          json.pincode customer.addresses.first.pincode
        else
          json.customer_name resource.customer_id
          json.latitude resource.customer_id
          json.longitude resource.customer_id
          json.delivery_address resource.customer_id
          json.mobile_no resource.customer_id
          json.pincode resource.customer_id
        end 
			end
		end 
	end
end