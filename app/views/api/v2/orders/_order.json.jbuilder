json.extract! order, :id, :source, :unit_id, :deliverable_id, :deliverable_type, :delivery_boy_id, :trash, :cancel_cause, :delivary_date, :created_at, :updated_at, :recorded_at, :consumer_id, :consumer_type, :checksum, :resource_type, :order_subtotal, :order_total_without_tax, :total_tax, :order_status_id, :customer_id, :third_party_order_id, :latitude, :longitude, :device_id, :billed, :order_sr_no, :otp_status, :operation_type, :delivery_type, :reservation_id
json.order_status order.order_status.name
json.recorded_date order.recorded_at.strftime("%d-%m-%Y")
json.recorded_time order.recorded_at.strftime("%I:%M %p")
json.date_of_delivery order.delivary_date.strftime("%d-%m-%Y")
json.delivary_time order.delivary_date.strftime("%I:%M %p")
json.delivery_otp order.deliverable_otp
_ext_order = ExternalOrder.find_by_order_id(order.id)
if _ext_order.present?
  json.ext_order_id JSON.parse(_ext_order.order)["details"]["merchant_ref_id"]
else
  json.ext_platforms nil
end

json.currency currency
if order.billed == 1
  if order.bill.status == 'paid'
    json.settlement_status 1
  else
    json.settlement_status 0  
  end
else
  json.settlement_status 0     
end
if order.order_details.first.menu_product.present?
  if order.order_details.first.menu_product.menu_card.section.present?
    json.section_type order.order_details.first.menu_product.menu_card.section.section_type
  else
    json.section_type ""
  end  
else
  json.section_type ""
end  
# Adding consumer info
_consumer_name = "#{order.consumer.profile.firstname.humanize} #{order.consumer.profile.lastname.humanize}" if order.consumer.present? and order.consumer.profile.present? and order.consumer.profile.firstname.present? and order.consumer.profile.lastname.present?
_consumer_name = "#{order.consumer.profile.firstname.humanize}" if order.consumer.present? and order.consumer.profile.present? and order.consumer.profile.firstname.present? and !order.consumer.profile.lastname.present?
_consumer_name ||= "#{order.consumer.email}" if order.consumer.present? and order.consumer.email.present?
if order.consumer_type == "Customer"
  _consumer_name ||= "#{order.consumer.mobile_no}" if order.consumer.present? and order.consumer.mobile_no.present?
end  
_consumer_name ||=""
json.consumer_name _consumer_name
# Adding deliverable details

json.deliverable do

  json.merge! order.deliverable.as_json
  json.more_details order.deliverable.additional_information if order.deliverable.present?
  json.additional_information order.deliverable.additional_information if order.deliverable.present?
  json.resource_type order.resource_type if order.resource_type.present?
end


# Adding order items
if @resources.include? 'order_items'
  json.order_items order.order_details do |item|
    json.extract! item, :id, :product_id, :menu_product_id, :product_name, :product_price, :customization_price, :unit_price_without_tax, :tax_amount, :unit_price_with_tax, :discount, :quantity, :subtotal, :trash, :cancel_cause, :bill_status, :remarks, :status, :sort_id, :created_at, :updated_at, :parcel, :preferences, :expiry_date, :product_unique_identity, :checksum, :lot_id, :hsn_code, :delivery_status, :color_name, :size_name, :lot_desc, :bill_destination_id, :item_remarks, :is_refund, :is_refandable, :return_qty, :is_returned, :item_preference
    if item.lot.present?
      json.mrp item.lot.mrp
    else  
      json.mrp item.lot_id
    end  
    if item.menu_product.present?
      json.delivery_mode item.menu_product.delivery_mode
      json.max_order_qty item.menu_product.max_order_qty 
    else
      json.delivery_mode ""
      json.max_order_qty 0
    end  
    
    json.product_unit item.product_unit_id.present? ? item.sold_item_unit.short_name : item.product.basic_unit
    json.sort_name item.sort.name
    # Adding order customizations
    json.customizations item.order_detail_combinations do |custom|
      json.extract! custom, :id, :product_id, :product_name, :product_price, :total_price
      json.quantity custom.combination_qty
    end

    # Adding order combos
    json.order_details_combos item.order_details_combos do |od_combo|
      json.extract! od_combo, :id, :product_id, :product_name, :quantity
      json.color_name od_combo.color.present? ? od_combo.color.name : ''
      json.size_name od_combo.size.present? ? od_combo.size.name : ''
      json.product_unique_identity od_combo.product_unique_identity
    end
    # Adding product tax info
    if @resources.include? 'item_tax'
      json.tax_group_name item.menu_product.tax_group.name
      json.tax_classes item.menu_product.tax_group.tax_classes, :id, :name, :ammount, :tax_type, :lower_limit, :upper_limit, :amount_type
    end
  end
end


# Adding unit info
if @resources.include? 'unit_info'
  json.unit do
    json.extract! order.unit, :id, :unit_name, :address, :landmark, :locality, :pincode, :city, :state, :country, :time_zone, :latitude, :longitude, :phone
    json.minimum_order_amount order.unit.unit_detail.options[:min_order_amount]
    json.delivery_charges order.unit.unit_detail.options[:delivery_charges]
    json.open_from order.unit.unit_detail.options[:open_from]
    json.open_to order.unit.unit_detail.options[:open_to]
    json.day_closing_time order.unit.unit_detail.options[:day_closing_time]
  end
end

if order.customer.present?
  json.customer do
    json.extract! order.customer, :id, :mobile_no
    if order.customer.profile.present?
      json.customer_name order.customer.customer_profile.customer_name
    end
    if order.customer.addresses.present?
      json.addresses order.customer.addresses
      json.delivery_address order.customer.addresses.first.delivery_address
      json.pincode order.customer.addresses.first.pincode
    end
  end
end

# Adding bill details
if @resources.include? 'bill_details'
  json.bill do
    _bill = order.bills.first
    if _bill.present?
      json.partial! 'api/v2/bills/bill', bill: _bill
    end
  end
end

if @resources.include? 'order_slots'
  json.order_slot do
    _order_slot = order.order_slots.first
    if _order_slot.present?
      json.slot_title _order_slot.slot.title
      json.start_time _order_slot.slot.start_time.strftime("%I:%M%p")
      json.end_time _order_slot.slot.end_time.strftime("%I:%M%p")
    end
  end
end

json.order_status_logs order.order_status_logs do |order_status_log|
  json.extract! order_status_log, :id, :order_id, :order_status_id, :order_status_name, :unit_id, :user_id
  json.created_at order_status_log.created_at.strftime("%d-%m-%Y %I:%M %p")
end