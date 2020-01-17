json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @external_orders.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @external_orders.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
	if params[:pagination].present? and params[:pagination] == 'yes' 
		json.data do
			json.count @count
			# json.external_orders @external_orders   #, partial: 'api/v2/external_orders/external_order', as: :external_order
      json.data @external_orders do |exo|
        json.id exo.id
        json.order_id exo.order_id
        json.unit_id exo.unit_id
        json.external_order_id exo.external_order_id
        json.order_source exo.order_source
        json.thirdparty_status exo.thirdparty_status
        json.customer exo.customer.present? ? JSON.parse(exo.customer) : exo.customer
        json.order exo.order.present? ? JSON.parse(exo.order) : exo.order
        json.created_at exo.created_at
        json.updated_at exo.updated_at
      end
		end
	else
  	# json.data @external_orders  # , partial: 'api/v2/external_orders/external_order', as: :external_order
    json.data @external_orders do |exo|
      json.id exo.id
      json.order_id exo.order_id
      json.unit_id exo.unit_id
      json.external_order_id exo.external_order_id
      json.order_source exo.order_source
      json.thirdparty_status exo.thirdparty_status
      json.customer exo.customer.present? ? JSON.parse(exo.customer) : exo.customer
      json.order exo.order.present? ? JSON.parse(exo.order) : exo.order
      json.created_at exo.created_at
      json.updated_at exo.updated_at
    end
  end	
end