json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @resources.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @resources.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  if @data_count == 'yes'
    json.data do
      json.data_count @resources_count
      json.resources @resources do |resource|
        json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :capacity, :price, :printer_id, :unique_identity_no, :parent_resource_id, :menu_card_id, :menu_product_id
        json.resource_type_id resource.resource_type_id
        json.resource_type resource.resource_type.name
        json.resource_state_id resource.resource_state_id 
        json.resource_state_name resource.resource_state.name
        json.resource_image resource.resource_image
        json.currency currency
        @reservations = Reservation.by_date_time_range(@from_datetime, @to_datetime).not_trash(0) if params[:start_date].present? && params[:end_date].present?
        @reservations = @reservations.by_slot(params[:slot_id]) if params[:slot_id].present?
        @parent_reservations = @reservations.map { |e| e.reservation_details.where(:resource_id => resource.id).map { |d| d } }.flatten if @reservations.present?
        if @reservations.present?
          if @parent_reservations.present? 
            if resource.child_resources.present?
              child_resources = resource.child_resources.select(:id).pluck(:id)
              child_reservation = @reservations.map { |e| e.reservation_details.set_resource_ids(child_resources).map { |d| d } }.flatten if @reservations.present?
              child_reservation = child_reservation.uniq{|x| x.resource_id}
              if child_resources.count == child_reservation.count
                json.is_avaliable false
              else
                json.is_avaliable true  
              end  
            else
              json.is_avaliable false
            end
          else
            if resource.child_resources.present?
              child_resources = resource.child_resources.select(:id).pluck(:id)
              child_reservation = @reservations.map { |e| e.reservation_details.set_resource_ids(child_resources).map { |d| d } }.flatten if @reservations.present?
              child_reservation = child_reservation.uniq{|x| x.resource_id}
              if child_resources.count == child_reservation.count
                json.is_avaliable false
              else
                json.is_avaliable true  
              end  
            else
              json.is_avaliable true  
            end
          end
        else
          json.is_avaliable true
        end
        if @extra.include? 'menu_product'
          if resource.menu_product.present?
            json.menu_product do
              json.extract! resource.menu_product, :id, :menu_category_id, :product_id, :mode, :sell_price, :sell_price_without_tax, :sort_id, :store_id, :updated_at, :is_buffet_product, :isdefault, :stock_status, :variable_id, :combo_id, :tax_group_id, :procured_price, :bill_destination_id, :stock_qty, :delivery_mode, :max_order_qty, :commission_capping, :commission_capping_type, :is_unit_currency, :unit_currency_price
              json.unit_currency resource.menu_product.menu_card.unit.unit_currency 
            end
          else
            json.menu_product Hash.new
          end    
        end  

        # json.availabilities resource.availabilities do |availability|
        #   if availability.available_date>= Date.today
        #     json.available_date availability.available_date
        #     json.day_of_week availability.available_date.strftime("%A")
        #     json.slot_id availability.slot_id
        #     json.slot_title availability.slot.title
        #     json.slot_start_time availability.slot.start_time
        #     json.slot_end_time availability.slot.end_time
        #     json.duration availability.slot.duration
        #   end 
        # end

        json.child_resources resource.child_resources do |child_resource|
          json.extract! child_resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :capacity, :price, :printer_id, :unique_identity_no, :parent_resource_id, :menu_card_id, :menu_product_id
          json.resource_type_id child_resource.resource_type_id
          json.resource_type child_resource.resource_type.name
          json.resource_state_id child_resource.resource_state_id 
          json.resource_state_name child_resource.resource_state.name
          json.resource_image child_resource.resource_image
          json.currency currency
          @child_reservations = @reservations.map { |e| e.reservation_details.where(:resource_id => child_resource.id).map { |d| d } }.flatten if @reservations.present?
          if !@child_reservations.present?
            json.is_avaliable true
          else
            json.is_avaliable false
          end  
          check_informations = Reservation.joins(:reservation_details).where(reservation_details:{:resource_id => child_resource.id}).map { |e| e.check_information }.flatten
          sorted_informations = check_informations.sort{|a,b| b.created_at <=> a.created_at }
          check_information = sorted_informations.select{|si| si.status = 'checked_in'}.first
          if check_information.present?
            json.reservation_id check_information.reservation_id 
          else
            json.reservation_id nil
          end  
          if @extra.include? 'menu_product'
            if child_resource.menu_product.present?
              json.menu_product do
                json.extract! child_resource.menu_product, :id, :menu_category_id, :product_id, :mode, :sell_price, :sell_price_without_tax, :sort_id, :store_id, :updated_at, :is_buffet_product, :isdefault, :stock_status, :variable_id, :combo_id, :tax_group_id, :procured_price, :bill_destination_id, :stock_qty, :delivery_mode, :max_order_qty, :commission_capping, :commission_capping_type, :is_unit_currency, :unit_currency_price
                json.unit_currency child_resource.menu_product.menu_card.unit.unit_currency 
              end
            else
              json.menu_product Hash.new
            end    
          end 
          # json.availabilities child_resource.availabilities do |availability|
          #   if availability.available_date>= Date.today
          #     json.available_date availability.available_date
          #     json.day_of_week availability.available_date.strftime("%A")
          #     json.slot_id availability.slot_id
          #     json.slot_title availability.slot.title
          #     json.slot_start_time availability.slot.start_time
          #     json.slot_end_time availability.slot.end_time
          #     json.duration availability.slot.duration
          #   end 
          # end
        end

      end       
    end   
  else  
    json.data @resources do |resource|
      json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :capacity, :price, :printer_id, :unique_identity_no, :parent_resource_id, :menu_card_id, :menu_product_id
      json.resource_type_id resource.resource_type_id
      json.resource_state_id resource.resource_state_id 
      json.resource_image resource.resource_image
      json.currency currency
      @reservations = Reservation.by_date_range(params[:start_date].to_date, params[:end_date].to_date).not_trash(0) if params[:start_date].present? && params[:end_date].present?
      @reservations = @reservations.by_slot(params[:slot_id]) if params[:slot_id].present?
      @parent_reservations = @reservations.map { |e| e.reservation_details.where(:resource_id => resource.id).map { |d| d } } if @reservations.present?
      if @reservations.present?
        if @parent_reservations[0].length < 1
          json.is_avaliable true
        else
          if resource.child_resources.present?
            child_resources = resource.child_resources.select(:id).pluck(:id)
            child_reservation = @reservations.map { |e| e.reservation_details.set_resource_ids(child_resources).map { |d| d } } if @reservations.present?
            child_reservation = child_reservation.uniq{|x| x.resource_id}
            if child_resources.count == child_reservation.count
              json.is_avaliable false
            else
              json.is_avaliable true  
            end  
          else
            json.is_avaliable false  
          end
        end 
      else
        json.is_avaliable true
      end   
      if @extra.include? 'menu_product'
        if resource.menu_product.present?
          json.menu_product do
            json.extract! resource.menu_product, :id, :menu_category_id, :product_id, :mode, :sell_price, :sell_price_without_tax, :sort_id, :store_id, :updated_at, :is_buffet_product, :isdefault, :stock_status, :variable_id, :combo_id, :tax_group_id, :procured_price, :bill_destination_id, :stock_qty, :delivery_mode, :max_order_qty, :commission_capping, :commission_capping_type, :is_unit_currency, :unit_currency_price
            json.unit_currency resource.menu_product.menu_card.unit.unit_currency 
          end
        else
          json.menu_product Hash.new
        end    
      end 
      # json.availabilities resource.availabilities do |availability|
      # 	if availability.available_date>= Date.today
      #   	json.available_date availability.available_date
      #     json.day_of_week availability.available_date.strftime("%A")
      #   	json.slot_id availability.slot_id
      #   	json.slot_title availability.slot.title
      #     json.slot_start_time availability.slot.start_time
      #     json.slot_end_time availability.slot.end_time
      #     json.duration availability.slot.duration
      #   end	
      # end

      json.child_resources resource.child_resources do |child_resource|
        json.extract! child_resource, :id, :name, :properties, :unit_id, :section_id, :user_id, :capacity, :price, :printer_id, :unique_identity_no, :parent_resource_id, :menu_card_id, :menu_product_id
        json.resource_type_id child_resource.resource_type_id
        json.resource_type child_resource.resource_type.name
        json.resource_state_id child_resource.resource_state_id 
        json.resource_state_name child_resource.resource_state.name
        json.resource_image child_resource.resource_image
        json.currency currency
        @child_reservations = @reservations.map { |e| e.reservation_details.where(:resource_id => child_resource.id).map { |d| d } }.flatten if @reservations.present?
        if !@child_reservations.present?
          json.is_avaliable true
        else
          json.is_avaliable false
        end  
        if @extra.include? 'menu_product'
          if child_resource.menu_product.present?
            json.menu_product do
              json.extract! child_resource.menu_product, :id, :menu_category_id, :product_id, :mode, :sell_price, :sell_price_without_tax, :sort_id, :store_id, :updated_at, :is_buffet_product, :isdefault, :stock_status, :variable_id, :combo_id, :tax_group_id, :procured_price, :bill_destination_id, :stock_qty, :delivery_mode, :max_order_qty, :commission_capping, :commission_capping_type, :is_unit_currency, :unit_currency_price
              json.unit_currency child_resource.menu_product.menu_card.unit.unit_currency 
            end
          else
            json.menu_product Hash.new
          end    
        end 
        # json.availabilities child_resource.availabilities do |availability|
        #   if availability.available_date>= Date.today
        #     json.available_date availability.available_date
        #     json.day_of_week availability.available_date.strftime("%A")
        #     json.slot_id availability.slot_id
        #     json.slot_title availability.slot.title
        #     json.slot_start_time availability.slot.start_time
        #     json.slot_end_time availability.slot.end_time
        #     json.duration availability.slot.duration
        #   end 
        # end
      end

    end
  end  
end
