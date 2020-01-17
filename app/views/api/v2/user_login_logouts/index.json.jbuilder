json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do 
	json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @login_details.count)
	json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @login_details.count)
	json.error_code @log[:log_serial] if @error.present? and @log.present?
	json.error_url @log[:log_url] if @error.present? and @log.present?
end

if @error.present?
	json.data Array.new
else
	json.data do
		json.count @count
		
		json.user_login_logout_details @login_details do |log_in_out|
			json.role_name log_in_out.user_role_name
			json.Name log_in_out.user.profile.firstname + " " + log_in_out.user.profile.lastname
			json.email log_in_out.user.email
			json.unit_name log_in_out.user.unit.unit_name
			json.sign_in_count log_in_out.user.sign_in_count
			json.user_id log_in_out.user_id
			json.sign_in_at log_in_out.sign_in_at
			json.sign_out_at log_in_out.sign_out_at
		end
	end
end
