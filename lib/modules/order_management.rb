module OrderManagement
###############################################
#### save a updated order_details
############################################### 
  
  # SMS send
  API_KEY       = 'Q2JRePQw7py'
  MobileNo      = '918250510764'
  SenderID      = 'YOTTOL'
  ServiceName   = 'TEMPLATE_BASED'
  API_BASE_URL  = "smsapi.24x7sms.com/api_2.0/SendSMS.aspx?APIKEY="
  # SMS send

  def self.save_order_details(order_details_id, quantity)
    
    ol = order_details_id.length
    ql = quantity.length
    if ol == ql
      i = 0
      while i < ol  do
        order_detail = OrderDetail.find(order_details_id[i])
        order_detail[:quantity] = quantity[i]
        order_detail.save 
        i +=1
      end
    end
  end 
###############################################
#### cancel created order
###############################################  
  def self.cancel_order(order_id, cancel_cause)
    order = Order.find(order_id)
    order.update_attributes(:trash => 1, :cancel_cause => cancel_cause)

    # SMS send
    if AppConfiguration.get_config_value('send_sms_on_status_change') == 'enabled'
      unit_name = order.unit.unit_detail.options[:order_sms_unit_name].present? ? order.unit.unit_detail.options[:order_sms_unit_name] : order.unit.unit_name
      message = 'Your order '+order.id.to_s+' has been cancelled. Thanks for using '+ unit_name+ '.'
      message = URI.encode(message)

      mobile_no = order.deliverable.customer.profile.contact_no if order.deliverable_type == "Address"  
      mobile_no = order.deliverable.profile.contact_no if order.deliverable_type == "Customer"    
      mobile_no ||= order.customer.profile.contact_no if order.customer_id.present?
      mobile_no = "91#{mobile_no}"
      uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{mobile_no}&SenderID=#{SenderID}&Message=#{message}&ServiceName=#{ServiceName}"
      rest_response = RestClient.get uri
    end
    # SMS send

    if order.order_details.present?
      order.order_details.each do |order_detail|
        OrderManagement::cancel_order_product(order_detail.id, cancel_cause)
      end
    end
  end
###############################################
#### cancel a product from an order
###############################################  
  def self.cancel_order_product(order_details_id, cancel_cause)
    order_detail = OrderDetail.find(order_details_id)
    order_detail.update_attributes(:trash => 1, :cancel_cause => cancel_cause, :status => 'canceled')
  end 
###############################################
#### update a created order status
###############################################    
  def self.update_order_status(order_id, order_status_id, user_id)
    order = Order.find(order_id)
    if OrderStatusLog.where("order_id =(?) AND order_status_id =(?)", order_id, order_status_id).length > 0
      return {:error => "Order ID #{order_id} is already passed through the Status ID #{order_status_id}"}
    else
      order[:order_status_id] = order_status_id
      # if OrderStatus.find(order_status_id).name.downcase == "delivered"
      #   Order.reduce_whole_order_stock(order, user_id)
      # end
      if order.save
        return {:success => "Order ID #{order_id} Status ID successfully changed to #{order_status_id}"}
      end

      # if order.save
      #   OrderManagement::save_order_status_log(order[:unit_id], user_id, order_id, order_status_id, order.order_status[:name])
      #   return {:message => "You have succesfully changed the status"}
      # end
    end
  end   
###############################################
  def self.update_order_state(order_id, order_status_id, user_id)
    order = Order.find(order_id)
    if OrderStatusLog.where("order_id =(?) AND order_status_id =(?)", order_id, order_status_id).length > 0
      return {:error => "Order ID #{order_id} is already passed through the Status ID #{order_status_id}"}
    else
      order[:order_status_id] = order_status_id
      if order.save 
        if order.order_details.present?
          order.order_details.each do |order_detail|
            order_detail.update_column(:status, 'approved')
          end
        end
        order.push_update_to_subscribers_for_approve
        return {:success => "Order ID #{order_id} Status ID successfully changed to #{order_status_id}"}
      end
    end
  end 
#####################################################
#### get order details by customer of hungryleopard
#####################################################

  def self.get_hl_orders()
    source = "hungryleopard"
    order = Order.where(["source=?",source])
    return order
  end

#####################################################

###############################################
#### update a created order status by source
###############################################    
  def self.get_total_sell_quantity_by_product_id(menu_product_id, source)
    #puts source
    if source.empty?
      _order_source = Order.where(:trash => 0).select('id')
    else
      _order_source = Order.where("source =? AND trash =?", source, 0).select('id')
    end
    
    #puts _order_source
    _sell_count = OrderDetail.where("menu_product_id =? AND order_id in(?) AND trash =?", menu_product_id, _order_source, 0).sum(:quantity)
  end
############################################### 

###############################################
#### get_total_sell_by_menu_product
###############################################    
  def self.get_total_sell_by_menu_product(product_id, unit_id, source)
    return_arr = {}
    if product_id.nil?
      _product_basic_unit = "N/A"
    else
      _product_basic_unit = ProductManagement::get_product_details_by_id(product_id)[:basic_unit]
    end
    
    #puts _product_basic_unit
    all_menu_card_ids_of_this_unit = MenuManagement::get_all_menu_card_id_by_unit_id(unit_id)
    menu_product_id = MenuProduct.where('product_id =? and menu_card_id in(?)', product_id, all_menu_card_ids_of_this_unit)
    total_sell_quantity = 0
    total_sell = 0
    if !menu_product_id.empty?
      total_sell_quantity = OrderManagement::get_total_sell_quantity_by_product_id(menu_product_id[0].id, source)
      #puts total_sell_quantity
      total_sell = (total_sell_quantity.to_i)*(menu_product_id[0].sell_price)
    # else
      # total_sell_quantity = 0
      # total_sell = 0
    end
    #puts return_arr[:total_sell_quantity]
    return_arr[:total_sell_quantity] = total_sell_quantity
    return_arr[:total_sell] =  total_sell
    return_arr[:product_basic_unit] =  _product_basic_unit
    return return_arr
  end  
###############################################

###############################################
#### get_total_sell_by_menu_product from all outlet and from all source
###############################################    
  def self.get_total_sell_by_menu_product_by_all(product_id)
    return_arr = {}
    if product_id.nil?
      _product_basic_unit = "N/A"
    else
      _product_basic_unit = ProductManagement::get_product_details_by_id(product_id)[:basic_unit]
    end
    
    #puts _product_basic_unit
    menu_product_id = MenuProduct.where(:product_id => product_id)
    total_sell_quantity = 0
    total_sell = 0
    if !menu_product_id.empty?
      total_sell_quantity = OrderManagement::get_total_sell_quantity_by_product_id(menu_product_id[0].id, "")
      #puts total_sell_quantity
      if !menu_product_id[0].sell_price.nil?
        total_sell = (total_sell_quantity.to_i)*(menu_product_id[0].sell_price)
      else
        total_sell = (total_sell_quantity.to_i)*0
      end
    # else
      # total_sell_quantity = 0
      # total_sell = 0
    end
    #puts return_arr[:total_sell_quantity]
    return_arr[:total_sell_quantity] = total_sell_quantity
    return_arr[:total_sell] =  total_sell
    return_arr[:product_basic_unit] =  _product_basic_unit
    return return_arr
  end  
###############################################

  def self.order_no_by_date(current_utc_date, unit_id)
    _today_order = Order.where("DATE(delivary_date) = ? AND unit_id =?", Date.today, unit_id).count
    return _today_order
  end
  
###############################################

  def self.save_order_status_log(unit_id, user_id, order_id, order_status_id, order_status_name)
    #puts unit_id
    _order_status_log = OrderStatusLog.new
    _order_status_log[:unit_id] = unit_id
    _order_status_log[:user_id] = user_id
    _order_status_log[:order_status_id] = order_status_id
    _order_status_log[:order_status_name] = order_status_name
    _order_status_log[:order_id] = order_id
    _order_status_log.save
  end

#############################################
  def self.change_product_unit(basic,required,ammount,quantity)
    final_quantity = ammount.to_f* quantity.to_f * (ProductUnit.find(required)).multiplier.to_f
  end

end