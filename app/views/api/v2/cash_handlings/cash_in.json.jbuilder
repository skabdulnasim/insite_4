json.status (@error.present? or @validation_errors.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message (@error.present? or @validation_errors.present?) ? I18n.t(:error_cash_in_not_created) : I18n.t(:success_cash_in_created)
  json.internal_message I18n.t(:success_cash_in_created)
  json.internal_message @validation_errors if @validation_errors.present?
  json.internal_message @error.message if @error.present?
end 
if @error.present? or @validation_errors.present?
  json.data Hash.new
else
  json.data do
    json.extract! @cash_in, :id, :user_id, :unit_id, :amount, :reason, :device_id, :recorded_at, :bill_serial_no  
    json.descriptions @cash_in.cash_in_descriptions do |description|
      json.extract! description, :id, :cash_in_id, :denomination_id, :count
      json.image description.denomination.image
      json.name description.denomination.name
      json.value description.denomination.value
    end 
  end  
end