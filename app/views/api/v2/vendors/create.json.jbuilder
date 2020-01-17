json.status (@error.present? or @validation_errors.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  if @status_code.present?
    json.status_code @status_code 
    json.internal_message @status_messge
    json.simple_message @status_messge
  else
    json.status_code (@error.present? or @validation_errors.present?) ? 500 : 200
    json.internal_message (@error.present? or @validation_errors.present?) ? I18n.t(:error_try_after_sometime) : I18n.t(:success_creating_vendor)
    json.simple_message @error.present? ? @error.message : I18n.t(:success_creating_vendor)
    json.simple_message @validation_errors if @validation_errors.present?
  end
end  
if @error.present? or @validation_errors.present?
  json.data Hash.new
else
  json.data do
    json.extract! @vendor, :name, :email, :phone, :address, :gst_hash, :latitude, :longitude, :unit_id, :recorded_at, :pan_no
    json.recorded_at @vendor.recorded_at.strftime("%Y-%m-%d %H:%M:%S")
    json.vendor_id @vendor.id
    json.vendor_products @vendor.vendor_products do |vendor_product|
      json.extract! vendor_product, :id
      json.product_id vendor_product.product_id
      json.product_name Product.find(vendor_product.product_id).name
      json.price vendor_product.price
      json.recorded_at vendor_product.recorded_at.strftime("%Y-%m-%d %H:%M:%S")
      if vendor_product.tax_group_id.present?
        tax_group = TaxGroup.find(vendor_product.tax_group_id)
        json.tax_group do
          json.extract! tax_group, :id, :name, :total_amnt, :fixed_amount
          json.tax_classes tax_group.active_tax_classes do |tax_class|
            json.extract! tax_class, :id, :name, :tax_type, :amount_type, :upper_limit, :lower_limit
            json.amount tax_class.ammount
          end
        end
      end 
    end
  end  
end