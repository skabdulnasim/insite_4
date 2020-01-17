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
    json.extract! @unit, :id, :unit_name, :address, :landmark, :locality, :pincode, :city, :state, :country, :time_zone, :latitude, :longitude, :phone, :unittype_id, :unit_image
    json.unit_type @unit.unittype.unit_type_name
    json.currency currency
    json.other_details do
      if @unit.unit_detail.present?
        unit_details = @unit.unit_detail
        #json.extract! @unit.unit_detail, :options, :updated_at
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
          json.bill_suffix unit_details.options[:bill_suffix]
          json.bill_prefix unit_details.options[:bill_prefix]
          json.order_sms_unit_name unit_details.options[:order_sms_unit_name]
          json.tin_number unit_details.options[:tin_number]
          json.bill_tax_details unit_details.options[:bill_tax_details]
          json.gst_code unit_details.options[:gst_code]
          json.pan_no unit_details.options[:pan_no]
          json.averages_cost unit_details.options[:averages_cost].to_i
          json.on_line_order unit_details.options[:on_line_order]
          json.day_allow_for_future_order unit_details.options[:day_allow_for_future_order]
          json.week_start_day unit_details.options[:week_start_day]
          json.standard_delivery_time unit_details.options[:standard_delivery_time]
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
              if @unit.slots.present?
                json.slots @unit.slots do |slot|
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
          json.more_info @unit.unit_more_infos do |unit_more_info|
            _more_info = unit_more_info.more_info
            json.extract! _more_info, :id , :name
          end
          json.outlet_types @unit.unit_outlet_types do |unit_outlet_type|
            _outlet_type = unit_outlet_type.outlet_type
            json.extract! _outlet_type, :id , :name
          end
          json.cusines @unit.unit_type_of_cusines do |unit_type_of_cusine|
            _cusine = unit_type_of_cusine.type_of_cuisine
            json.extract! _cusine, :id , :name
          end
          json.atmospheres @unit.unit_atmospheres do |unit_atmosphere|
            _atmosphere = unit_atmosphere.atmosphere
            json.extract! _atmosphere, :id , :name
          end
        end
        json.updated_at unit_details.updated_at
      end
      json.images @unit.unit_images do |image|
        json.image image.image
      end
    end
    ### Adding extra resources based on requirement
    if @resources.present?
      ## Adding 'sections' resource
      if @resources.include?('sections')
        json.sections @unit.sections do |section|
          json.extract! section, :id, :name, :section_type
          json.bill_header_text section.bill_header
          json.bill_footer_text section.bill_footer
          json.last_bill_serial Bill.last_section_bill_serial_number(@unit.id,@device_id,section.id)
          # Adding 'menu_cards'(active only) resource
          if @resources.include? 'menu_cards'
            json.menu_cards section.menu_cards.order("priority asc").order("position") do |menu_card|
              json.extract! menu_card, :id, :name, :master_menu_id, :scope, :updated_at, :menu_type, :priority, :position, :image, :operation_type, :menu_classification
            end
          end
          # Adding 'resource_type'(active only) resource
          if @resources.include? 'resource_type'
            if ResourceType.by_section_id(section.id).present?
              json.resource_type do
                json.extract! ResourceType.by_section_id(section.id).first, :id, :name, :section_id 
              end
            else
              json.resource_type Hash.new
            end  
          end
          # Adding 'tables'(active only) resource
          if @resources.include? 'tables'
            json.tables section.tables do |table|
              json.extract! table, :id, :name, :capacity, :table_shape, :user_id, :table_state_id
              json.table_state table.table_state.name
            end
          end
          # Adding 'resources'(active only) resource
          if @resources.include? 'resources'
            json.resources section.resources do |resource|
              json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :printer_id, :parent_resource_id
              json.resource_type_id resource.resource_type_id
              json.resource_type resource.resource_type.name if resource.resource_type.present?
              json.resource_state_id resource.resource_state_id
              json.resource_state_name resource.resource_state.name
              json.availabilities resource.availabilities do |availability|
                if availability.available_date>= Date.today
                  json.available_date availability.available_date
                  json.day_of_week availability.available_date.strftime("%A")
                  json.slot_id availability.slot_id
                  json.slot_title availability.slot.title
                  json.slot_start_time availability.slot.start_time
                  json.slot_end_time availability.slot.end_time
                  json.duration availability.slot.duration
                end
              end
            end
          end
          if section.section_type == 'sourcing'
            if @resources.include? 'vendor_pjp' and params[:user_id].present?
              json.vendor_pjp @pjp_date 
            end 
          end   
          ### Ading Tsp details
          if @resources.include? 'tsp' and params[:user_id].present?
            json.tsp do
              json.Sunday Resource.active_only.by_section(section.id).by_user(params[:user_id],"Sunday") do |resource|
                json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :printer_id,:customer_id   
                json.resource_type resource.resource_type.name
                if resource.customer_id.present?
                  customer = Customer.find(resource.customer_id)
                  json.customer_name customer.customer_profile.customer_name
                  json.latitude customer.addresses.first.latitude
                  json.longitude customer.addresses.first.longitude
                  json.delivery_address customer.addresses.first.delivery_address
                  json.mobile_no customer.mobile_no
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end    
                else
                  json.customer_name resource.customer_id
                  json.latitude resource.customer_id
                  json.longitude resource.customer_id
                  json.delivery_address resource.customer_id
                  json.mobile_no resource.customer_id
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                end
              end
              json.Monday Resource.active_only.by_section(section.id).by_user(params[:user_id],"Monday") do |resource|
                json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :printer_id,:customer_id   
                json.resource_type resource.resource_type.name
                if resource.customer_id.present?
                  customer = Customer.find(resource.customer_id)
                  json.customer_name customer.customer_profile.customer_name
                  json.latitude customer.addresses.first.latitude
                  json.longitude customer.addresses.first.longitude
                  json.delivery_address customer.addresses.first.delivery_address
                  json.mobile_no customer.mobile_no
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                else
                  json.customer_name resource.customer_id
                  json.latitude resource.customer_id
                  json.longitude resource.customer_id
                  json.delivery_address resource.customer_id
                  json.mobile_no resource.customer_id
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                end   
              end
              json.Tuesday Resource.active_only.by_section(section.id).by_user(params[:user_id],"Tuesday") do |resource|
                json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :printer_id,:customer_id  
                json.resource_type resource.resource_type.name 
                if resource.customer_id.present?
                  customer = Customer.find(resource.customer_id)
                  json.customer_name customer.customer_profile.customer_name
                  json.latitude customer.addresses.first.latitude
                  json.longitude customer.addresses.first.longitude
                  json.delivery_address customer.addresses.first.delivery_address
                  json.mobile_no customer.mobile_no
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                else
                  json.customer_name resource.customer_id
                  json.latitude resource.customer_id
                  json.longitude resource.customer_id
                  json.delivery_address resource.customer_id
                  json.mobile_no resource.customer_id
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                end   
              end
              json.Wednesday Resource.active_only.by_section(section.id).by_user(params[:user_id],"Wednesday") do |resource|
                json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :printer_id,:customer_id   
                json.resource_type resource.resource_type.name
                if resource.customer_id.present?
                  customer = Customer.find(resource.customer_id)
                  json.customer_name customer.customer_profile.customer_name
                  json.latitude customer.addresses.first.latitude
                  json.longitude customer.addresses.first.longitude
                  json.delivery_address customer.addresses.first.delivery_address
                  json.mobile_no customer.mobile_no
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                else
                  json.customer_name resource.customer_id
                  json.latitude resource.customer_id
                  json.longitude resource.customer_id
                  json.delivery_address resource.customer_id
                  json.mobile_no resource.customer_id
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                end   
              end
              json.Thursday Resource.active_only.by_section(section.id).by_user(params[:user_id],"Thursday") do |resource|
                json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :printer_id,:customer_id   
                json.resource_type resource.resource_type.name
                if resource.customer_id.present?
                  customer = Customer.find(resource.customer_id)
                  json.customer_name customer.customer_profile.customer_name
                  json.latitude customer.addresses.first.latitude
                  json.longitude customer.addresses.first.longitude
                  json.delivery_address customer.addresses.first.delivery_address
                  json.mobile_no customer.mobile_no
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                else
                  json.customer_name resource.customer_id
                  json.latitude resource.customer_id
                  json.longitude resource.customer_id
                  json.delivery_address resource.customer_id
                  json.mobile_no resource.customer_id
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                end   
              end
              json.Friday Resource.active_only.by_section(section.id).by_user(params[:user_id],"Friday") do |resource|
                json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :printer_id,:customer_id   
                json.resource_type resource.resource_type.name
                if resource.customer_id.present?
                  customer = Customer.find(resource.customer_id)
                  json.customer_name customer.customer_profile.customer_name
                  json.latitude customer.addresses.first.latitude
                  json.longitude customer.addresses.first.longitude
                  json.delivery_address customer.addresses.first.delivery_address
                  json.mobile_no customer.mobile_no
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                else
                  json.customer_name resource.customer_id
                  json.latitude resource.customer_id
                  json.longitude resource.customer_id
                  json.delivery_address resource.customer_id
                  json.mobile_no resource.customer_id
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                end   
              end
              json.Saturday Resource.active_only.by_section(section.id).by_user(params[:user_id],"Saturday") do |resource|
                json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :printer_id,:customer_id   
                json.resource_type resource.resource_type.name
                if resource.customer_id.present?
                  customer = Customer.find(resource.customer_id)
                  json.customer_name customer.customer_profile.customer_name
                  json.latitude customer.addresses.first.latitude
                  json.longitude customer.addresses.first.longitude
                  json.delivery_address customer.addresses.first.delivery_address
                  json.mobile_no customer.mobile_no
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                else
                  json.customer_name resource.customer_id
                  json.latitude resource.customer_id
                  json.longitude resource.customer_id
                  json.delivery_address resource.customer_id
                  json.mobile_no resource.customer_id
                  if customer.customer_state_id.present?
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state customer.customer_state.name
                  else
                    json.customer_state_id customer.customer_state_id 
                    json.customer_state ''
                  end  
                end   
              end
            end
          end
          # Adding 'tax_groups'(active only) resource
          puts "**************************"
          puts @resources.inspect
          puts "**************************"
          if @resources.include? 'tax_groups'
            json.tax_groups section.tax_groups do |tax_group|
              json.extract! tax_group, :id, :name, :total_amnt, :fixed_amount
              json.tax_classes tax_group.active_tax_classes do |tax_class|
                json.extract! tax_class, :id, :name, :tax_type, :amount_type, :upper_limit, :lower_limit, :operation_type
                json.amount tax_class.ammount
              end
            end
          end

        end
      end
      ### Adding 'Bill destination' resource
      if @resources.include? 'bill_destinations'
        json.bill_destinations @unit.bill_destinations do |bill_destination|
          json.extract! bill_destination, :id, :name, :bill_footer, :bill_header
          json.last_bill_serial Bill.last_bill_destination_serial_number(@unit.id,@device_id,bill_destination.id)
        end
      end
      ### Adding 'stores' resource
      if @resources.include? 'stores'
        json.stores @unit.stores do |store|
          json.extract! store, :id, :name, :store_type
        end
      end
      ### Adding 'sorts' resource
      if @resources.include? 'sorts'
        json.sorts @unit.sorts do |sort|
          json.extract! sort, :id, :name
        end
      end
      ### Adding 'printers' resource
      if @resources.include? 'printers'
        json.printers @unit.printers do |printer|
          json.extract! printer, :id, :ip, :name, :assignable_type, :assignable_id
          json.assignable_name printer.assignable.name
        end
      end

      ### Adding 'users' resource
      if @resources.include? 'users'
        json.users @unit.users do |user|
          json.extract! user, :id, :email, :key_phrase
          json.user_name "#{user.profile.firstname} #{user.profile.lastname}"
        end
      end

      ### Adding "User Work Status" resource
      if @resources.include? 'work_statuses'
        json.work_statuses UserWorkStatus::WORKSTATUS do |work_status|
          json.work_status work_status
        end
      end

      ### Adding "Customer State" resource
      if @resources.include? 'customer_states'
        json.customer_states CustomerState.all do |cs|
          json.extract! cs, :id, :name
        end
      end

      ### Adding "Delivery Charges" resource
      if @resources.include? 'delivery_charges'
        json.delivery_charges @unit.delivery_charges do |dc|
          json.extract! dc, :id, :lower_limit, :upper_limit, :delivery_charge
        end
      end

      ### Adding "Cancelation policy" resource
      if @resources.include? 'cancelation_policy'
        json.cancelation_policy do
          if @unit.cancelation_policy.present?
            json.extract! @unit.cancelation_policy, :id, :cancellation_allowed, :is_refundable, :plolicy, :cancelation_not_allowed_state, :unit_id, :cancelation_allowed_since_deliverable
            json.cancelation_causes @unit.cancelation_policy.cancelation_causes do |cc|
              json.extract! cc, :id, :title
            end
          end  
        end
      end

      ### Adding "Return Ploicy" resource
      if @resources.include? 'return_policy'
        json.return_policy do
          if @unit.return_policy.present?
            store = @unit.stores.return_store.first
            json.extract! @unit.return_policy, :id, :return_allowed, :is_refundable, :policy, :return_allowed_after_deliverable, :unit_id, :return_alowed_on_order_state, :return_charge, :return_charge_type
            json.return_store_id store.id if store.present?
            json.return_causes @unit.return_policy.return_causes do |rc|
              json.extract! rc, :id, :title
            end
          end  
        end
      end

      ### Adding 'advertisements' resource
      if @resources.include? 'advertisements'
        json.advertisements @unit.advertisements do |add|
          json.extract! add, :name, :updated_at,:menu_card_id, :position
          json.media_contents add.advertisement_galleries do |media|
            json.extract! media, :advertisement_image_url
          end
          json.image add.advertisement_galleries.last.advertisement_image_url
        end
      end
      if @resources.include? 'accepted_currencies'
        json.accepted_currenies AcceptedCurrency.all.each do |accepted_currency|
          json.extract! accepted_currency, :id,:multiplier
          json.currency_id accepted_currency.country_currency_id
          json.currency accepted_currency.country_currency.currency
          json.country accepted_currency.country_currency.counrty
          json.flag accepted_currency.country_currency.flag
          json.currency_code accepted_currency.country_currency.currency_code
          json.currency_symbol accepted_currency.country_currency.symbol
        end
      end
    end
  end
end