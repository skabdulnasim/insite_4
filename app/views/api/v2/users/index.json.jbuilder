json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? @error.message : I18n.t(:success_user_login)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_user_login)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.users @users.each do |user|
    json.extract! user, :id,:email
    json.extract! user.profile, :full_name,:contact_no,:address,:city
    json.unit_name user.unit.unit_name
    json.role user.users_role.role.name
  end
end