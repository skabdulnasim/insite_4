json.extract! proforma, :id, :customer_id, :device_id, :discount, :grand_total, :proforma_amount, :recorded_at, :remarks, :roundoff, :serial_no, :status, :tax_amount, :unit_id, :user_id, :vehicle_id, :billed

# Customer Details
json.customer proforma.customer, :gstin
json.address proforma.customer.addresses, :pincode

# Customer profile
json.customer_details proforma.customer.customer_profile, :firstname, :lastname, :pan_no, :address

# Unit Details
json.unit_details proforma.unit, :unit_name, :address, :pincode
json.unit_details_gst proforma.unit.unit_detail, :options

json.orders proforma.order_proformas do |o_p|
	json.extract! o_p.order, :id, :unit_id, :source, :device_id, :consumer_id, :consumer_type, :deliverable_id, :deliverable_type, :order_status_id, :order_total_without_tax, :total_tax, :total_discount, :order_subtotal, :trash, :cancel_cause, :created_at, :updated_at, :checksum, :customer_id, :latitude, :longitude, :third_party_order_id, :order_sr_no, :otp_status
  json.order_status o_p.order.order_status.name
  # Adding order items
  json.order_items o_p.order.order_details do |item|
    json.extract! item, :id, :product_id, :menu_product_id, :product_name, :product_price, :customization_price, :unit_price_without_tax, :tax_amount, :unit_price_with_tax, :discount, :quantity, :subtotal, :trash, :cancel_cause, :bill_status, :remarks, :status, :sort_id, :created_at, :updated_at,:is_returned, :store_id, :product_unique_identity, :expiry_date, :properties, :hsn_code, :checksum, :lot_id, :item_status, :discount_percentage, :delivery_status, :color_name, :size_name, :lot_desc, :bill_destination_id, :item_remarks, :is_refund, :is_refandable, :return_qty
    json.tax_details JSON.parse(item.tax_details)
    json.product_unit item.product.basic_unit
    # Adding order customizations
    json.customizations item.order_detail_combinations do |custom|
      json.extract! custom, :id, :product_id, :product_name, :product_price, :total_price
      json.quantity custom.combination_qty
    end
  end
end