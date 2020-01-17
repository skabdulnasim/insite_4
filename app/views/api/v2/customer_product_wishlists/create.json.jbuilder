json.status (@error.present? or @validation_errors.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message (@error.present? or @validation_errors.present?) ? I18n.t(:error_try_after_sometime) : I18n.t(:success_wishlist_generated)
  json.internal_message I18n.t(:success_wishlist_generated)
  json.internal_message @validation_errors if @validation_errors.present?
  json.internal_message @error.message if @error.present?
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present? or @validation_errors.present?
  json.data Hash.new
else
  json.data do
    json.partial! 'api/v2/customer_product_wishlists/wishlist', wishlist: @wishlist
  end  
end