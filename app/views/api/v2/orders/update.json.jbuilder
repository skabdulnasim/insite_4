json.status (@error.present? or @validation_errors.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message (@error.present? or @validation_errors.present?) ? I18n.t(:error_order_update) : I18n.t(:success_order_update)
  json.internal_message I18n.t(:success_order_update)
  json.internal_message @validation_errors if @validation_errors.present?
  json.internal_message @error.message if @error.present?
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present? or @validation_errors.present?
	json.data Hash.new
else
	json.data do
		json.extract! @order, :id, :source, :unit_id, :deliverable_id, :deliverable_type, :delivery_boy_id, :trash, :cancel_cause, :delivary_date, :created_at, :updated_at, :recorded_at, :consumer_id, :consumer_type
		json.order_details @order.order_details
    if @res.present?
      json.paytmres @res
    end
	end
end