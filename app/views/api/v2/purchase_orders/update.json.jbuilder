json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_purchase_order_receive) : I18n.t(:success_purchase_order_receive)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_purchase_order_receive)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
	json.data Array.new
else
	json.data do
		json.extract! @stock_purchase, :id, :purchase_order_id, :status, :store_id, :attachment, :attachment_content_type
	end
end