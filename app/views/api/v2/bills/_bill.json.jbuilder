json.extract! bill, :id, :serial_no, :device_id, :bill_amount, :tax_amount, :discount, :grand_total, :unit_id, :status, :pax, :remarks, :created_at, :updated_at, :recorded_at, :biller_id, :biller_type, :deliverable_type, :deliverable_id, :customer_id, :delivery_charges, :section_id, :bill_destination_id, :lite_device_id, :is_service_charge, :boh_amount, :reprint_count, :split_roundoff, :suffix, :prefix, :proforma_id
json.synced_at bill.created_at.strftime("%d-%m-%Y, %I:%M %p")
json.sync_date bill.created_at.strftime("%d-%m-%Y")
json.roundoff BigDecimal(bill.roundoff.to_s).floor(2)
if bill.section_id.present?
  json.bill_section bill.section.name
else
  json.bill_section ""
end   
# Adding biller info
_biller_name = "#{bill.biller.profile.firstname.humanize}" if bill.biller.present? and bill.biller.profile.present? and bill.biller.profile.firstname.present? and !bill.biller.profile.lastname.present?
_biller_name = "#{bill.biller.profile.firstname.humanize} #{bill.biller.profile.lastname.humanize}" if bill.biller.present? and bill.biller.profile.present? and bill.biller.profile.firstname.present? and bill.biller.profile.lastname.present?
if bill.biller_type == "Customer"
  _biller_name ||= "#{bill.biller.mobile_no}" if bill.biller.mobile_no.present?
else
  _biller_name ||= "#{bill.biller.email}" if bill.biller.present?
end  
_biller_name ||=""
json.biller_name _biller_name
# Adding deliverable details
if @resources.include? 'delivery_details'
  json.deliverable do
    json.merge! bill.deliverable.as_json
    json.more_details bill.deliverable.additional_information
  end
end
# Adding orders
if @resources.include? 'order_items'
  json.orders bill.orders do |order|
    json.extract! order, :id, :unit_id, :source, :device_id, :consumer_id, :consumer_type, :deliverable_id, :deliverable_type, :order_status_id, :order_total_without_tax, :total_tax, :total_discount, :order_subtotal, :trash, :cancel_cause, :created_at, :updated_at, :checksum, :customer_id, :latitude, :longitude, :third_party_order_id, :order_sr_no, :otp_status
    json.order_status order.order_status.name
    # Adding order items
    json.order_items order.order_details do |item|
      json.extract! item, :id, :product_id, :menu_product_id, :product_name, :product_price, :customization_price, :unit_price_without_tax, :tax_amount, :unit_price_with_tax, :discount, :quantity, :subtotal, :trash, :cancel_cause, :bill_status, :remarks, :status, :sort_id, :created_at, :updated_at,:is_returned, :store_id, :product_unique_identity, :expiry_date, :properties, :hsn_code, :checksum, :lot_id, :item_status, :discount_percentage, :delivery_status, :color_name, :size_name, :lot_desc, :bill_destination_id, :item_remarks, :is_refund, :is_refandable, :return_qty
      json.tax_details JSON.parse(item.tax_details)
      json.product_unit item.product.basic_unit
      if item.lot.present?
        json.mrp item.lot.mrp
      else  
        json.mrp item.lot_id
      end 
      # Adding order customizations
      json.customizations item.order_detail_combinations do |custom|
        json.extract! custom, :id, :product_id, :product_name, :product_price, :total_price
        json.quantity custom.combination_qty
      end
    end
  end
end
# Adding bill taxes
if @resources.include? 'tax_details'
  json.taxes bill.bill_tax_amounts do |tax|
    json.extract! tax, :tax_amount
    json.tax_class_name tax.tax_class.name
    json.tax_class_type tax.tax_class.tax_type
    json.tax_class_amount tax.tax_class.ammount
    json.tax_class_amount_type tax.tax_class.amount_type
    json.operation_type tax.tax_class.operation_type
  end
end
# Adding bill discounts
if @resources.include? 'discount_details'
  json.discounts bill.bill_discounts do |discount|
    json.extract! discount, :discount_amount, :remarks , :is_merchant_discount, :title, :rate
  end    
end
# Adding payment info
if @resources.include? 'payment_details'
  
  if bill.bill_splits.present?
    json.bill_splits bill.bill_splits do |bill_split|
      json.extract! bill_split, :id, :bill_id, :bill_amount, :tax_amount, :discount, :grand_total, :split_type, :unit_id, :user_id, :status, :created_at, :recorded_at, :remarks, :checksum
      _biller_name = "#{bill_split.biller.profile.firstname.humanize} #{bill_split.biller.profile.lastname.humanize}" if bill_split.biller.present? and bill_split.biller.profile.present?
      _biller_name ||= "#{bill_split.biller.email}" if bill_split.biller.present?
      _biller_name ||=""
      json.bill_boher_name _biller_name
      if bill.customer.present?
        json.customer do
          json.extract! bill.customer, :id, :mobile_no
          if bill.customer.profile.present?
            json.customer_name "#{bill.customer.profile.firstname} " "#{bill.customer.profile.lastname}" 
          end
        end
      end  
      if bill_split.split_settlement.present?
        json.payments bill_split.split_settlement.payments do |payment|
          json.extract! payment, :id, :paymentmode_id, :paymentmode_type, :created_at, :updated_at
          json.paid_amount payment.paymentmode.amount
            _payment_details = payment.paymentmode.third_party_payment_option_name if payment.paymentmode_type == 'ThirdPartyPayment'
            _payment_details ||= payment.paymentmode.room_name if payment.paymentmode_type == 'RoomPayment'
            _payment_details ||= payment.paymentmode.user_name if payment.paymentmode_type == 'AccountPayment'
            _payment_details ||= payment.paymentmode.name_on_card if payment.paymentmode_type == 'LoyaltyCardPayment'
            _payment_details ||= ""
            json.paymentmode_details _payment_details
        end
      end
      if bill_split.bill_split_products.present?
        json.bill_split_products bill_split.bill_split_products do |bill_split_product|
          json.extract! bill_split_product, :id, :bill_split_id, :quantity, :price, :subtotal, :tax_amount, :unit_price_with_tax
          json.product_name bill_split_product.product.name
          json.menu_product_id bill_split_product.order_detail.menu_product_id
          json.order_detail_id bill_split_product.order_detail_id
        end
      end  
    end  
  end 
  if bill.settlement.present?
    json.settlement do
      json.partial! 'api/v2/settlements/settlement', settlement: bill.settlement
    end
  else
    json.settlement Hash.new
  end
end
# Adding unit details
if @resources.include? 'unit_details'
  json.unit do
    json.extract! bill.unit, :id, :unit_name, :address, :landmark, :locality, :pincode, :city, :state, :phone, :unit_image
    json.bill_header_text bill.unit.unit_detail.present? ? bill.unit.unit_detail.options[:bill_header_text] : ""
    json.bill_footer_text bill.unit.unit_detail.present? ? bill.unit.unit_detail.options[:bill_footer_text] : ""
    json.bill_tax_details bill.unit.unit_detail.present? ? bill.unit.unit_detail.options[:bill_tax_details] : ""
    json.gst_code bill.unit.unit_detail.present? ?bill.unit.unit_detail.options[:gst_code] : ""
    json.pan_no bill.unit.unit_detail.present? ?bill.unit.unit_detail.options[:pan_no] : ""
  end
end

if bill.customer.present?
  json.customer do
    json.extract! bill.customer, :id, :mobile_no, :gstin
    if bill.customer.profile.present?
      json.customer_name "#{bill.customer.profile.firstname} " "#{bill.customer.profile.lastname}"
    end
    if bill.customer.addresses.present?
      json.addresses bill.customer.addresses.first
    end
  end
end

# Adding rservation details
if @resources.include? 'reservation_details'
  if bill.reservation.present?
    json.reservation do
      json.extract! bill.reservation, :id, :customer_id, :resource_id, :created_at
      json.reservation_date bill.reservation.reservation_date.strftime("%d-%m-%Y")
      if bill.reservation.start_date.present?
        json.start_time bill.reservation.start_date.strftime("%d-%m-%Y, %I:%M %p")
        json.end_time bill.reservation.end_date.strftime("%d-%m-%Y, %I:%M %p")
      else
        json.start_time bill.reservation.start_time.strftime("%I:%M %p")
        json.end_time bill.reservation.end_time.strftime("%I:%M %p") 
      end  
      json.customre_name "#{bill.reservation.customer.customer_profile.firstname} " "#{bill.reservation.customer.customer_profile.lastname}"
      json.customer_phone_no bill.reservation.customer.mobile_no
      json.customer_age age(bill.reservation.customer.customer_profile.dob)
      json.customer_gender bill.reservation.customer.customer_profile.gender
      json.resource_name bill.reservation.resource.name
      json.resource_properties bill.reservation.resource.properties
      json.settlement_amount bill.settlement.bill_amount
    end
  end  
end
