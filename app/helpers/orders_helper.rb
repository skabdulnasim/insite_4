module OrdersHelper
  ###############################################  For rest api #########################################################
  def order_create_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :POST, '/orders.json', "Place an order"
    param :order_status_id, String, :desc => "order status id", :required => true
    param :delivery_boy_id, String, :desc => "Delivery boy id", :required => false
    param :unit_id, String, :desc => "unit id", :required => true
    param :source, String, :desc => "sources like hlapp/hlportal/inhouse etc", :required => true
    param :serial_no, String, :desc => "A random string unique for all order under a bill", :required => false
    param :consumer_type, String, :desc => "user/customer", :required => true
    param :consumer_id, String, :desc => "user_id/customer_id", :required => true
    param :deliverable_type, String, :desc => "table/room/address", :required => true
    param :deliverable_id, String, :desc => "table_id/room_id/address_id", :required => true
    param :delivary_date, String, :desc => "Date of delivery. Format : 2015-01-13 09:30:16", :required => true
    param :recorded_at, String, :desc => "Order record datetime", :required => false
    param :order_details, String, :desc => "the order details in json format.like -> [{'menu_product_id':1,'quantity':2,'parcel':0,'preferences':'Low chilli','order_detail_combinations':[{'menu_product_combination_id':1,'combination_qty':2,'total_price':30}]},{'menu_product_id':2,'parcel':1,'quantity':2,'preferences':'High chilli','order_detail_combinations':[{'menu_product_combination_id':2,'combination_qty':4,'total_price':80}]}]", :required => true
    error :code => 401, :desc => "Unauthorized"
    description "Place an order"
    formats ['json', 'html']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  end

  def order_update_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :PUTS, '/orders/:id.json', "Update an order"
    param :deliverable_type, String, :desc => "table/room/address", :required => false
    param :deliverable_id, String, :desc => "table_id/room_id/address_id", :required => false
    error :code => 401, :desc => "Unauthorized"
    description "Update an order, provide only those param those you want to update."
    formats ['json', 'html']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  end

  def order_index_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :GET, '/orders.json', "Get orders"
    param :unit_id, String, :desc => "Unit ID", :required => false
    param :order_status_id, String, :desc => "order status id", :required => false
    param :order_source, String, :desc => "hlapp/hlportal/inhouse", :required => false
    param :deliverable_type, String, :desc => "table/room/address", :required => false
    param :deliverable_id, String, :desc => "table_id/room_id/address_id", :required => false
    param :consumer_type, String, :desc => "user/customer", :required => false
    param :consumer_id, String, :desc => "user_id/customer_id", :required => false
    param :billed, String, :desc => "billed=1/not billed=0", :required => false
    param :orders_after_id, String, :desc => "If this parameter will be present in request, you will get all orders after that id", :required => false
    error :code => 401, :desc => "Unauthorized"
    description "Url : http://test.lvh.me:3000/orders.json?device_id=YOTTO05&unit_id=3&consumer_type=user&consumer_id=6&order_status_id=1&order_source=inhouse&deliverable_type=table&deliverable_id=1"
    formats ['json', 'html']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  end

  def get_order_by_customer_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :GET, '/orders/get_order_by_customer.json', "Get all orders from hungyleopard"
    error :code => 401, :desc => "Unauthorized"
    description "Url : http://lazeez.stewot.com/orders/get_order_by_customer.json?device_id=YOTTO05"
    formats ['json', 'jsonp']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  end

  def cancel_order_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :GET, '/orders/cancel_order.json', "Cancel an whole order."
    error :code => 401, :desc => "Unauthorized"
    param :id, String, :desc => "Order ID", :required => false
    description "Url : http://lazeez.stewot.com/orders/cancel_order.json?device_id=YOTTO05&id=112"
    formats ['json', 'jsonp']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  end

  def cancel_order_product_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :GET, '/orders/cancel_order_product.json', "Cancel product from an order."
    error :code => 401, :desc => "Unauthorized"
    param :abs_url, String, :desc => "reirection url", :required => false
    param :order_details_id, String, :desc => "Order Details ID", :required => true
    param :cancel_cause, String, :desc => "Cancellation cause", :required => true
    description "Url : http://lazeez.stewot.com/orders/cancel_order_product.json?device_id=YOTTO05&order_details_id=213"
    formats ['json', 'jsonp']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  end

  def update_order_status_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :POST, '/orders/update_order_status.json', "Change the status of an order. Ex : new, approved, Prepeared... etc"
    error :code => 401, :desc => "Unauthorized"
    param :user_id, String, :desc => "User ID", :required => false
    param :order_ids, String, :desc => "order_ids json as =>  [{'id':'125'},{'id':'126'}]", :required => true
    param :order_status_id, String, :desc => "Status ID", :required => true
    description "Url : http://lazeez.stewot.com/orders/update_order_status.json"
    formats ['json', 'jsonp']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  end

  def order_by_delivery_boy_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :GET, '/orders/order_by_delivery_boy.json', "Get orders for a particular delivery boy"
    param :delivery_boy_id, String, :desc => "Delivery ID", :required => true
    param :unit_id, String, :desc => "Unit ID", :required => false
    param :order_status_id, String, :desc => "order status id", :required => false
    param :order_source, String, :desc => "hlapp/hlportal/inhouse", :required => false
    param :deliverable_type, String, :desc => "table/room/address", :required => false
    param :deliverable_id, String, :desc => "table_id/room_id/address_id", :required => false
    param :consumer_type, String, :desc => "user/customer", :required => false
    param :consumer_id, String, :desc => "user_id/customer_id", :required => false
    param :billed, String, :desc => "billed=1/not billed=0", :required => false
    error :code => 401, :desc => "Unauthorized"
    description "Url : http://dev.selfordering.com/orders/order_by_delivery_boy.json?delivery_boy_id=1&device_id=YOTTO05"
    formats ['json', 'html']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  end


  def data_content(object)
    content_tag "Details" do
      object.order_details.collect {|od| concat("#{od.product_name} : #{od[:quantity]} #{od.product.basic_unit} , ")}
    end
  end
  ################################################################################################################################

  #####################################################  link helper ############################################################
  def cancel_order_link(object)
    if object.trash != 1
      link_to("#{orders_cancel_order_path}/?id=#{object.id}", html_options = {:class => "", :data => { :confirm => t('.confirm', :default => t('helpers.links.confirm', :default => 'Are you sure?')) }, :title => 'Cancel this order'}) do
        "Cancel Order"
        # tag("i", class: "fa fa-ban fa-lg")
      end
    end
  end

  def edit_order_link(object)
    link_to("#{edit_order_path(object)}", html_options = {:class => "btn btn-xs btn-info", :title => 'Edit order'}) do
      tag("i", class: "fa fa-edit fa-lg")
    end
  end

  def show_order_link(object)
    link_to("#{order_path(object)}", html_options = {:class => "", "data-container" => "body", "title" => "Order ##{object.id}", "data-content" => data_content(object), "data-placement" => "left", "data-toggle" => "popover", :type => "button"}) do
      "View Order Details"
      # tag("i", class: "fa fa-search-plus fa-lg")
    end
  end
  #################################################################################################################


  ####################################################  class methods ###############################################
  def show_delivery_name(object)
    if ['Address','Customer'].include?(object.deliverable_type)
      content_tag(:span, "#{object.deliverable_type}")
    elsif ['Resource'].include?(object.deliverable_type)
      if object.reservation.present?
        if object.reservation.reservation_details.present?
          reservation_details = object.reservation.reservation_details
          reservation_details.each do |reservation_detail|
            if reservation_detail.is_parent == "yes"
              r_name = reservation_detail.resource.name
              logger.debug content_tag(:span,"#{r_name}", :class => 'badge orange')
            else
              r_name = reservation_detail.resource.name
              logger.debug content_tag(:span,"#{r_name}", :class => 'badge blue')
            end
          end
        end
      else
        if object.resource_type.present?
          content_tag(:span,"#{object.resource_type}: #{object.deliverable.name}") if object.deliverable.present?
        else
          content_tag(:span,"Retail Shop: #{object.deliverable.name}")
        end
      end
    else  
      content_tag(:span, "#{object.deliverable_type}: #{object.deliverable.name}")
    end
  end

  def get_order_delivery_details object
    concat(content_tag(:h6, "Order deliverable to #{object.deliverable_type}", :class => 'margin-t-b-2'))
    if object.deliverable_type == "Address"
      concat(content_tag(:b, "#{object.deliverable.receiver_first_name} #{object.deliverable.receiver_last_name}"))
      concat(content_tag(:h6, "#{object.deliverable.delivery_address}", :class => 'margin-t-b-2'))
      concat(content_tag(:h6, "#{object.deliverable.landmark}, #{object.deliverable.city} - #{object.deliverable.pincode}", :class => 'margin-t-b-2'))
      concat(content_tag(:h6, "Contact: #{object.deliverable.contact_no}", :class => 'margin-t-b-2'))
    elsif object.deliverable_type == "Customer"
      concat(content_tag(:b, "#{object.deliverable.additional_information.firstname} #{object.deliverable.additional_information.lastname}"))
      concat(content_tag(:h6, "#{object.deliverable.mobile_no}", :class => 'margin-t-b-2'))
    elsif object.deliverable_type == "Section" or object.deliverable_type == "Table"
      concat(content_tag(:b, "#{object.deliverable.name}"))
      concat(content_tag(:h6, "ID: #{object.deliverable_id}", :class => 'margin-t-b-2'))
    end
  end

  def show_order_status(object)
    if object.trash == 1
      content_tag(:p, "Canceled", :style => "color:red; font-weight:bold;")
    else
      content_tag(:span, "#{object.order_status.name}", :class => "m-label margin-l-none", :style => "background-color:#{object.order_status.color_code};")
    end
  end

  def show_order_source(object)
    case object.source.downcase
      when "inhouse"
        tag("i", class: "fa fa-home fa-lg", :title => 'Inhouse Orders')
      when "hungryleopard"
        tag("i", class: "fa fa-desktop fa-lg", :title => 'Portal Orders')
      when "hlportal"
        tag("i", class: "fa fa-desktop fa-lg", :title => 'Portal Orders')
      when "hlapp"
        tag("i", class: "fa fa-mobile fa-lg", :title => 'Mobile Orders')
      when "takeaway"
        tag("i", class: "fa fa-phone-square fa-lg", :title => 'Take Away Orders')
      else
        content_tag(:p, "#{object.source}", :style => "font-weight:bold;")
    end
  end

  def show_order_details(object)
    link_to("#", html_options = {:class => "btn btn-lg btn-success order_details", :title => 'Order details', :style => "font-size: 11px;display:none;"}) do
      object.order_details.each do |od|
        concat "#{od.product_name} : #{od[:quantity]} #{od.product.basic_unit}"
        tag("br")
      end
    end
  end

  def billed_order(object)
    if object.bill.present? and object.bill.paid?
      tag("i", class: "mdi-action-done-all smaller", style: "color:#4cae4c", :title => 'Billed')
    elsif object.billed == 1
      tag("i", class: "mdi-navigation-check smaller", style: "color:#4cae4c", :title=>'Billed')
    end
  end

  def order_stock_issue_status(object)
    if object.is_stock_debited == false && object.trash != 1
      tag("i", class: "mdi-av-new-releases smaller red-text remove-icon-#{object.id}", title: "Stock not issued")
    end
  end

  def get_order_details_for_tsp(tsp_id,from_datetime,to_datetime)
    order_details_id_for_order = Order.by_consumer_id(tsp_id).by_consumer_type('User').by_recorded_at(@from_datetime,@to_datetime).not_canceled.map{|order| order.order_details.map{|od| od.id}}.flatten
    orderdetails = OrderDetail.where(:id => order_details_id_for_order,:trash=>0)
    return orderdetails
  end
  
  def get_requisitions_for_tsp(tsp_id,from_datetime,to_datetime)
    requisitions_list = StoreRequisition.by_user_id(tsp_id).by_date_range(from_datetime,to_datetime).pluck(:id)
    requisition_details = StoreRequisitionMetum.by_requistions_in(requisitions_list)
    return requisition_details
  end
  
  def get_order_details_for_resource(resource_id,from_datetime,to_datetime)
    order_details_id_for_order = Order.resource_orders(resource_id).by_consumer_type('User').by_recorded_at(@from_datetime,@to_datetime).not_canceled.map{|order| order.order_details.map{|od| od.id}}.flatten
    orderdetails = OrderDetail.where(:id => order_details_id_for_order,:trash=>0)
  end

  def get_group_order_details_for_resource(resource_id,from_datetime,to_datetime,unit_id,report_mode)
    order_details_id_for_order = Order.resource_orders(resource_id).by_unit_id(unit_id).by_recorded_at(@from_datetime,@to_datetime).not_canceled.map{|order| order.order_details.map{|od| od.id}}.flatten
    if report_mode == 'delivery_date'
      orderdetails = OrderDetail.select("date(delivary_date) as date, sum(quantity) as total_sale, sum(subtotal) as total_price,product_name,product_id").group("date(delivary_date),product_name,product_id").where(:id => order_details_id_for_order,:trash=>0)
    else
      orderdetails = OrderDetail.select("sum(quantity) as total_sale, sum(subtotal) as total_price,product_name,product_id").group("product_name,product_id").where(:id => order_details_id_for_order,:trash=>0)
    end  
    return orderdetails
  end
  #to get group orders by product name for tsp sales report
  def get_group_order_details_for_tsp(tsp_id,from_date,to_date,store_id)
    resources = UserResource.by_user(tsp_id).by_date_range(params[:from_date],params[:to_date]).select("resource_id").uniq.pluck(:resource_id)
    orders = Order.by_recorded_at(from_date,to_date).set_resources(resources)
    # orders = Order.by_consumer_type('User').by_consumer_id(tsp_id).by_recorded_at(from_date,to_date).not_canceled
    orders = orders.set_store_id(store_id) if store_id.present?
    order_ids = orders.pluck(:id)
    order_details = OrderDetail.select("product_id,product_name , sum(quantity) as quantity, sum(subtotal) as sub_total").group("product_name,product_id").by_order_ids(order_ids).valid_item
    return order_details
  end
end
