json.status (@error.present? or @validation_errors.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message (@error.present? or @validation_errors.present?) ? I18n.t(:error_try_after_sometime) : I18n.t(:success_creating_vendor_contract)
  json.internal_message I18n.t(:success_creating_vendor_contract) if !@validation_errors.present? and !@error.present?
  json.internal_message @validation_errors if @validation_errors.present?
  json.internal_message @error.message if @error.present?
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present? or @validation_errors.present?
  json.data Hash.new
else
  json.data do 
  	json.extract! @vendor_contract, :id, :grand_total,:latitude, :longitude, :total_contract_price, :total_tax_amount, :unit_id, :vendor_id, :visited_by, :created_at, :updated_at
    json.recorded_at @vendor_contract.recorded_at.strftime("%Y-%m-%d %H:%M:%S")
  	json.vendor_product_price @vendor_contract.vendor_product_prices if @vendor_contract.vendor_product_prices.present?
  end
end