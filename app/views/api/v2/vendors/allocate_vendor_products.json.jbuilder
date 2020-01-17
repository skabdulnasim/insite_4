json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.status_code 200
  json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_allocate_vendor_products)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_allocate_vendor_products)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Array.new
else
  json.data do
    json.vendor_id @vendor.id
    json.name @vendor.name
    json.vendor_products @vendor.vendor_products.set_product_id_in(@newly_allocated_products) do |vendor_product|
      json.extract! vendor_product, :id
      json.product_id vendor_product.product_id
      json.name Product.find(vendor_product.product_id).name
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