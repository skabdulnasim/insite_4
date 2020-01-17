json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? "Error! No customer found." : "Customer found successfully."
  json.internal_message @error.present? ? @error.message : "Customer found successfully."
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
	json.data do
		json.id @user.id
		json.firstname @user.profile.firstname
		json.lastname @user.profile.lastname
		json.email @user.email
		json.unit_id @user.unit_id
		json.children User.user_children(@user.id) do |children|
			json.id children.id
			json.firstname children.profile.firstname
			json.lastname children.profile.lastname
			json.email children.email
			json.unit_id children.unit_id
		end
	end
end