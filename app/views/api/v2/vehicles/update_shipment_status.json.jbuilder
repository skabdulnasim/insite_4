json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
	if @status == "20"
	  json.simple_message @error.present? ? I18n.t(:error_stock_ship) : I18n.t(:success_pick_up)
	  json.internal_message @error.present? ? @error.message : I18n.t(:success_pick_up)
	end  
	if @status == "30"
		json.simple_message @error.present? ? I18n.t(:error_stock_ship) : I18n.t(:success_delivered)
	  json.internal_message @error.present? ? @error.message : I18n.t(:success_delivered)
	end
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Hash.new
else
	json.data do
    json.partial! 'api/v2/vehicles/stock_transfer', object: @stock_transfer
  end 
end