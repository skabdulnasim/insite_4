json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_unit_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_unit_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do
    json.extract! @lot, :id, :menu_product_id, :mode, :sell_price, :sell_price_without_tax, :sku, :stock_qty, :tax_group_id, :product_id, :expiry_date, :stock_id, :procured_price, :mrp, :menu_card_id, :color_name, :size_name, :model, :color_id, :size_id, :lot_desc, :created_at
    json.sale_rules @lot.sale_rules do |sale_rule|
      json.extract! sale_rule, :id, :name, :status, :sale_rule_type, :valid_from, :valid_till, :specific_type
    end
    json.lot_for_every_purchase AppConfiguration.get_config_value('lot_for_every_purchase')
    # if AppConfiguration.get_config_value('lot_for_every_purchase') == "enabled"
    #   json.po_details @lot.stock.stock_transaction
    #   json.stock_price @lot.stock.stock_price
    # end
  end
end