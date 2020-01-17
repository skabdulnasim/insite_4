class UnitDetail < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :unit
  attr_accessible :options, :unit_id
  serialize :options

  scope :set_unit, lambda {|unit_id|where(["unit_id=?", unit_id])}
  days = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

  #def self.save_unit_details(free_home_delevery, min_order_amount, daily_sales_target, payment_options, reservation, cuisine_type, atmosphere, more_info, outlet_type, open_from, open_to, resturant_time_slot, day_closing_time, current_user_info, bill_footer, bill_header, order_sms_unit_name="", tin_number="", bill_tax_details="", gst_code, delivery_charges, averages_cost, on_line_order, cancellation_allowed, cancellation_allowed_since, cancellation_refund, table_reservation_timings, min_book_charge_for_two_table_on_week_days, min_book_charge_for_two_table_on_weekend_days, min_book_charge_for_two_table_on_special_days, maximum_advance_days_allowed_for_reservation, reservation_cancellation_allowed_without_charge, reservation_cancellation_allowed, refund_dates)

  def self.save_unit_details(free_home_delevery, min_order_amount, daily_sales_target, payment_options, reservation, cuisine_type, atmosphere, more_info, outlet_type, open_from, open_to, resturant_time_slot, day_closing_time, current_user_info, bill_footer, bill_header, paynear_merchant_api_key, paynear_partner_api_key, gst_code, delivery_charges, averages_cost, on_line_order, cancellation_allowed, cancellation_allowed_since, cancellation_refund, table_reservation_timings, min_book_charge_for_two_table_on_week_days, min_book_charge_for_two_table_on_weekend_days, min_book_charge_for_two_table_on_special_days, maximum_advance_days_allowed_for_reservation, reservation_cancellation_allowed_without_charge, reservation_cancellation_allowed, refund_dates,order_sms_unit_name, bill_tax_details, tin_number, preauth, reservation_confirmation_without_charge, days_for_confirmation_of_reservation_without_charge, preauth_percentage_for_order, access_token, environment, merchant_id, public_key, private_key, day_allow_for_future_order,week_start_day,day_allow_for_order_slot,standard_delivery_time, pan_no, slot_applicable_from,bill_suffix,bill_prefix)
    current_unit = Unit.find(current_user_info.unit_id)
    if current_unit.unit_detail.present?
      unit_detail = current_unit.unit_detail
    else
      unit_detail = UnitDetail.new(unit_detail)
      unit_detail[:unit_id] = current_unit.id
    end
    branch_details = {}
    branch_details[:payment_options] = payment_options.present? ? payment_options : []
    branch_details[:cuisine_type] = cuisine_type.present? ? cuisine_type : []
    branch_details[:atmosphere] = atmosphere.present? ? atmosphere : []
    branch_details[:more_info] = more_info.present? ? more_info : []
    branch_details[:outlet_type] = outlet_type.present? ? outlet_type : []

    branch_details[:min_order_amount] = min_order_amount
    branch_details[:daily_sales_target] = daily_sales_target
    branch_details[:day_allow_for_future_order] = day_allow_for_future_order
    branch_details[:day_allow_for_order_slot] = day_allow_for_order_slot
    branch_details[:free_home_delevery] = free_home_delevery
    branch_details[:open_from] = open_from
    branch_details[:open_to] = open_to
    branch_details[:day_closing_time] = day_closing_time
    branch_details[:resturant_time_slot] = resturant_time_slot
    branch_details[:standard_delivery_time] = standard_delivery_time
    branch_details[:bill_footer_text] = bill_footer
    branch_details[:bill_header_text] = bill_header
    branch_details[:order_sms_unit_name] = order_sms_unit_name
    branch_details[:tin_number] = tin_number
    branch_details[:bill_tax_details] = bill_tax_details
    branch_details[:gst_code] = gst_code
    branch_details[:pan_no] = pan_no
    branch_details[:delivery_charges] = delivery_charges
    branch_details[:averages_cost] = averages_cost
    branch_details[:on_line_order] = on_line_order
    branch_details[:week_start_day] = week_start_day
    branch_details[:slot_applicable_from] = slot_applicable_from
    branch_details[:bill_suffix] = bill_suffix
    branch_details[:bill_prefix] = bill_prefix
    #Reservation configure
    branch_details[:cancellation_allowed] = cancellation_allowed
    branch_details[:cancellation_allowed_since] = cancellation_allowed_since
    branch_details[:cancellation_refund] = cancellation_refund
    branch_details[:reservation] = reservation
    branch_details[:table_reservation_timings] = table_reservation_timings
    branch_details[:min_book_charge_for_two_table_on_week_days] = min_book_charge_for_two_table_on_week_days
    branch_details[:min_book_charge_for_two_table_on_weekend_days] = min_book_charge_for_two_table_on_weekend_days
    branch_details[:min_book_charge_for_two_table_on_special_days] = min_book_charge_for_two_table_on_special_days
    branch_details[:maximum_advance_days_allowed_for_reservation] = maximum_advance_days_allowed_for_reservation
    branch_details[:reservation_cancellation_allowed_without_charge] = reservation_cancellation_allowed_without_charge
    branch_details[:reservation_cancellation_allowed] = reservation_cancellation_allowed
    branch_details[:refund_dates] = refund_dates
    branch_details[:preauth] = preauth
    branch_details[:reservation_confirmation_without_charge] = reservation_confirmation_without_charge
    branch_details[:days_for_confirmation_of_reservation_without_charge] = days_for_confirmation_of_reservation_without_charge
    branch_details[:preauth_percentage_for_order] = preauth_percentage_for_order

    #Paypal Configuration
    branch_details[:access_token] = access_token
    branch_details[:environment] = environment
    branch_details[:merchant_id] = merchant_id
    branch_details[:public_key] = public_key
    branch_details[:private_key] = private_key
    
    # branch_details_json = JSON.generate(branch_details)
    branch_details_json = branch_details
    unit_detail[:options] = branch_details_json
    unit_detail.save
    return unit_detail
  end
end
# {"payment_options":[],"cuisine_type":[],"atmosphere":[],"min_order_amount":"600","free_home_delevery":"Not available","reservation":"No","open_from":"09.00 AM","open_to":"09.00 PM","resturant_time_slot":"60"}