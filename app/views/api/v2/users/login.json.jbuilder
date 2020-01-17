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
  json.data do
    json.extract! @user, :id, :email, :unit_id, :key_phrase, :auth_token, :custom_sync
    json.extract! @user_unit, :unit_name
    json.extract! @user.profile, :firstname, :lastname, :contact_no
    json.user_role @user.role.name if @user.role.present?
    ### Adding extra resources based on requirement
    if @resources.present?
      ## Adding 'capabilities' resource
      json.capabilities @capabilities if @resources.include? 'capabilities' 
    end
    json.last_bill_serial @last_bill_serial
    json.last_proforma_serial @last_proforma_serial
    json.primary_store @user_unit.stores.physical.primary.first
    json.currency Account.find_by_subdomain(request.subdomain).currency.presence || "Rs"
    json.push_server_ip "#{FAYE_SERVER_IP}"
  end
end