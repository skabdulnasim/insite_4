json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:sucess_transaction)
  json.internal_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:sucess_transaction)
end
if @error.present?
  json.data @error
else
  json.data @res  
end