json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? "Sorry!! Could not find any branches" : "#{@units.count} branches loaded."
  json.internal_message @error.present? ? @error.message : "#{@units.count} units loaded."
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Array.new
else
  json.data(@units) do |unit|
    json.extract! unit, :id, :unit_name, :address, :landmark, :locality, :pincode, :city, :state, :country, :time_zone, :latitude, :longitude, :phone, :unittype_id, :unit_image
    json.currency currency
    json.unit_type unit.unittype.unit_type_name
    json.url api_v2_unit_path(unit, format: :json)
    #json.other_details unit.unit_detail, :options, :updated_at if unit.unit_detail.present?
    json.other_details do
      if unit.unit_detail.present?
        unit_details = unit.unit_detail
        json.options do
          json.min_order_amount unit_details.options[:min_order_amount]
          json.daily_sales_target unit_details.options[:daily_sales_target]
          json.free_home_delevery unit_details.options[:free_home_delevery]
          json.reservation unit_details.options[:reservation]
          json.open_from unit_details.options[:open_from]
          json.open_to unit_details.options[:open_to]
          json.day_closing_time unit_details.options[:day_closing_time]
          json.resturant_time_slot unit_details.options[:resturant_time_slot]
          json.bill_footer_text unit_details.options[:bill_footer_text]
          json.bill_header_text unit_details.options[:bill_header_text]
          json.order_sms_unit_name unit_details.options[:order_sms_unit_name]
          json.tin_number unit_details.options[:tin_number]
          json.bill_tax_details unit_details.options[:bill_tax_details]
          json.gst_code unit_details.options[:gst_code]
          json.pan_no unit_details.options[:pan_no]
          json.standard_delivery_time unit_details.options[:standard_delivery_time]
          json.delivery_charges unit_details.options[:delivery_charges].to_i
          json.averages_cost unit_details.options[:averages_cost].to_i
          json.on_line_order unit_details.options[:on_line_order]
          json.day_allow_for_future_order unit_details.options[:day_allow_for_future_order]
          json.week_start_day unit_details.options[:week_start_day]
          if params[:reservation] == 'yes'
            json.reservations do
              json.cancellation_allowed unit_details.options[:cancellation_allowed]
              json.cancellation_allowed_since unit_details.options[:cancellation_allowed_since]
              json.cancellation_refund unit_details.options[:cancellation_refund]
              json.table_reservation_timings unit_details.options[:table_reservation_timings]
              json.min_book_charge_for_two_table_on_week_days unit_details.options[:min_book_charge_for_two_table_on_week_days]
              json.min_book_charge_for_two_table_on_weekend_days unit_details.options[:min_book_charge_for_two_table_on_weekend_days]
              json.min_book_charge_for_two_table_on_special_days unit_details.options[:min_book_charge_for_two_table_on_special_days]
              json.maximum_advance_days_allowed_for_reservation unit_details.options[:maximum_advance_days_allowed_for_reservation].to_i
              json.reservation_cancellation_allowed_without_charge unit_details.options[:reservation_cancellation_allowed_without_charge].to_i
              json.reservation_cancellation_allowed unit_details.options[:reservation_cancellation_allowed]
              json.refund_dates unit_details.options[:refund_dates]
              json.reservation_confirmation_without_charge unit_details.options[:reservation_confirmation_without_charge]
              json.days_for_confirmation_of_reservation_without_charge unit_details.options[:days_for_confirmation_of_reservation_without_charge]
              json.preauth_percentage_for_order unit_details.options[:preauth_percentage_for_order]
              if unit.slots.present?
                json.slots unit.slots do |slot|
                  json.extract! slot, :id, :title, :start_time, :end_time, :duration
                end
              end  
            end
          end
          json.paypals do
            json.access_token unit_details.options[:access_token]
            json.environment unit_details.options[:environment]
            json.merchant_id unit_details.options[:merchant_id]
            json.public_key unit_details.options[:public_key]
            json.private_key unit_details.options[:private_key]
          end
          json.more_info unit.unit_more_infos do |unit_more_info|
            _more_info = unit_more_info.more_info
            json.extract! _more_info, :id , :name
          end
          json.outlet_types unit.unit_outlet_types do |unit_outlet_type|
            _outlet_type = unit_outlet_type.outlet_type
            json.extract! _outlet_type, :id , :name
          end
          json.cusines unit.unit_type_of_cusines do |unit_type_of_cusine|
            _cusine = unit_type_of_cusine.type_of_cuisine
            json.extract! _cusine, :id , :name
          end
          json.atmospheres unit.unit_atmospheres do |unit_atmosphere|
            _atmosphere = unit_atmosphere.atmosphere
            json.extract! _atmosphere, :id , :name
          end

        end
        json.updated_at unit_details.updated_at
      end
      json.images unit.unit_images do |image|
        json.image image.image
      end
    end

    # Adding menu cards if menu card scope is available
    menu_card = MenuCard.set_unit(unit.id).not_trashed.set_scope(params[:menu_card_scope]).set_mode(1).first if params[:menu_card_scope].present?
    json.menu_card menu_card, :id, :master_menu_id, :name, :scope, :section_id, :updated_at, :menu_type if params[:menu_card_scope].present? and menu_card.present?

    # Adding section and its active menu card
    if params[:active_menu_card].present? and params[:active_menu_card] == "yes"
      json.sections unit.sections do |section|
        json.extract! section, :id , :name, :section_type
        json.menu_cards section.menu_cards do |menu_card|
          json.extract! menu_card, :id, :name, :master_menu_id, :scope, :updated_at, :menu_type, :operation_type
        end
      end
    end

    ### Adding "Delivery Charges" resource
    json.delivery_charges unit.delivery_charges do |dc|
      json.extract! dc, :id, :lower_limit, :upper_limit, :delivery_charge
    end

  end
end