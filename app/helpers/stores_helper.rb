module StoresHelper

  def get_store_type_logo(store_type)
      if store_type == "physical_store"
        image_tag("icons/Parcel-blue-128.png", width: '100', :class => "")
      elsif store_type == "virtual_store"
        image_tag("icons/Despeckle-128.png", width: '100', :class => "")
      elsif store_type == "kitchen_store"
        image_tag("icons/Parcel-blue-128.png", width: '100', :class => "")
      elsif store_type == "return_store"
        image_tag("icons/Load-Man-Returns-128.png", width: '100', :class => "")
      elsif store_type == "waste_bin"
        image_tag("icons/waste-bin.jpeg", width: '100', :class => "")
      end  
  end

  # => Store type tag in store listing
  def store_type_tag(store_type,options={})
    options[:physical_text]  ||= 'Physical Store'
    options[:virtual_text] ||= 'Virtual Store'
    options[:kitchen_text] ||= 'Production Center'
    options[:return_text] ||= 'Return Store'

    if store_type == "physical_store"
      content_tag(:span, options[:physical_text], :class => 'm-label blue')
    elsif store_type == "virtual_store"
      content_tag(:span, options[:virtual_text], :class => 'm-label orange')
    elsif store_type == "kitchen_store"
      content_tag(:span, options[:kitchen_text], :class => 'm-label teal')
    elsif store_type == "return_store"
      content_tag(:span, options[:return_text], :class => 'label label-danger')
    end
  end

  def store_priority_tag(store_priority,options={})
    options[:primary_text]  ||= 'Primary Store'
    if store_priority == "primary_store"
      content_tag(:span, options[:primary_text], :class => 'm-label green')
    end
  end

  def get_store_link_by_store_type(store,options={})
    options[:pysical]  ||= 'Go to store'
    options[:kitchen] ||= 'Go to store'
    options[:return] ||= 'Go to Return Store'
    options[:waste_bin] ||= 'Go to Waste Bin'
    if store.store_type == "physical_store"
      link_to(options[:pysical], store_path(store), :class=>"m-btn green float-r margin-r-10 waves-effect waves-light")
    elsif store.store_type == "kitchen_store"
      link_to(options[:kitchen], kitchen_store_store_path(store), :class=>"m-btn orange float-r margin-r-10 waves-effect waves-light")
    elsif store.store_type == "return_store"
      link_to(options[:return], return_store_store_path(store), :class=>"m-btn green float-r margin-r-10 waves-effect waves-light")
    elsif store.store_type == "waste_bin"
      link_to(options[:waste_bin], store_path(store), :class=>"m-btn green float-r margin-r-10 waves-effect waves-light")
    end
  end

  def po_status_tag(status,options={})
    options[:not_received]  ||= 'Not received yet'
    options[:received] ||= 'Received'
    options[:partially_received] = "Partially Received"

    if status == "1"
      content_tag(:span, options[:not_received], :class => 'm-label red')
    elsif status == "2"
      content_tag(:span, options[:received], :class => 'm-label green')
    elsif status == "3"
      content_tag(:span, options[:partially_received], :class => 'm-label cyan')
    end
  end
  # => Active or inactive css class for stock_purchase indexing
  def po_status_class(status)
    if status == '1'
      return 'module_alert'
    elsif status == '2'
      return 'module_active'
    end
  end

  def req_status_tag(status,options={})
    options[:new]  ||= 'New'
    options[:rejected] ||= 'Rejected'
    options[:approved] ||= 'Approved'
    options[:sent] ||= 'Stock Issued'
    if status == "1"
      content_tag(:span, options[:new], :class => 'label label-primary')
    elsif status == "2"
      content_tag(:span, options[:rejected], :class => 'label label-danger')
    elsif status == "3"
      content_tag(:span, options[:approved], :class => 'label label-success')
    elsif status == "4"
      content_tag(:span, options[:sent], :class => 'label label-default')
    end
  end

  def get_status(status,options={})
    options[:new]  ||= 'New'
    options[:rejected] ||= 'Rejected'
    options[:approved] ||= 'Approved'
    options[:sent] ||= 'Stock Issued'
    if status == "1"
      options[:new]
    elsif status == "2"
      options[:rejected]
    elsif status == "3"
      options[:approved]
    elsif status == "4"
      options[:sent]
    end
  end

  def req_status_class(status)
    if status == '1'
      return 'module_primary'
    elsif status == '2'
      return 'module_alert'
    elsif status == '3'
      return 'module_active'
    elsif status == '4'
      return 'module_inactive'
    end
  end

  def get_activity_status_logo(activity_id,status)
    if activity_id == 2
      if status == '10'
        image_tag("icons/Polling-Box-128.png", height: '40', width: '40')
      elsif status == '20'
        image_tag("icons/Shipped-128.png", height: '40', width: '40')
      elsif status == '30'
        image_tag("icons/Load-Man-128.png", height: '40', width: '40')
      elsif status == '50'
        image_tag("icons/Command-Undo-128.png", height: '40', width: '40')
      elsif status == '60'
        image_tag("icons/Load-Man-Returns-128.png", height: '40', width: '40')
      elsif status == '90'
        image_tag("icons/Check-returns-128.png", height: '40', width: '40')
      elsif status == '100'
        image_tag("icons/Check-128.png", height: '40', width: '40')
      end
    elsif activity_id == 3
      if status == '1'
        image_tag("icons/Meat-Chicken-Kebab-128.png", height: '40', width: '40')
      elsif status == '2'
        image_tag("icons/Check-128.png", height: '40', width: '40')
      end
    elsif activity_id == 4
      if status == '5'
        image_tag("icons/Polling-Box-128.png", height: '40', width: '40')
      elsif status == '6'
        image_tag("icons/Check-128.png", height: '40', width: '40')
      end
    end
  end

  def transfer_status_class(activity,status)
    if activity == 2
      if status == '10' || status == '20' || status == '30'
        return 'module_primary'
      elsif status == '50' || status == '60'
        return 'module_alert'
      elsif status == '100' || status == '90'
        return 'module_active'
      end
    elsif activity == 3
      if status == '1'
        return 'module_primary'
      elsif status == "2"
        return 'module_active'
      end
    elsif activity == 4
      if status == '5'
        return 'module_primary'
      elsif status == "6"
        return 'module_active'
      end
    end
  end

  def get_receive_date(activity, status, update_date)
    if (activity == 2 && (status == "100" || status == "90")) || (activity == 3 && status == "2")|| (activity == 4 && status == "6")
      content_tag(:span, "Received on : #{update_date.strftime('%d %b %Y, %I:%M %p')}")
    end
  end

  def transfer_status_tag(activity,status,options={})
    if activity == 2
      options[:packed]  ||= 'Packed and ready for shipment'
      options[:shipped] ||= 'Shipped'
      options[:delivering] ||= 'Delivering shipment'
      options[:returning] ||= 'Shipment returned'
      options[:return_delivering] ||= 'Delivering return shipment'
      options[:return_delivered] ||= 'Return shipment received'
      options[:delivered] ||= 'Delivered and added to stock'
      if status == "10"
        content_tag(:span, options[:packed], :class => 'label label-primary')
      elsif status == "20"
        content_tag(:span, options[:shipped], :class => 'label label-info')
      elsif status == "30"
        content_tag(:span, options[:delivering], :class => 'label label-warning')
      elsif status == "50"
        content_tag(:span, options[:returning], :class => 'label label-danger')
      elsif status == "60"
        content_tag(:span, options[:return_delivering], :class => 'label label-warning')
      elsif status == "90"
        content_tag(:span, options[:return_delivered], :class => 'label label-info')
      elsif status == "100"
        content_tag(:span, options[:delivered], :class => 'label label-success')
      elsif status == '0'
        content_tag(:span, 'Incomplete', :class => 'label label-danger')
      end
    elsif activity == 3
      options[:sent]  ||= 'Not received yet'
      options[:received] ||= 'Received'
      if status == "1"
        content_tag(:span, options[:sent], :class => 'label label-primary')
      elsif status == "2"
        content_tag(:span, options[:received], :class => 'label label-success')
      elsif status == '0'
        content_tag(:span, 'Incomplete', :class => 'label label-danger')
      end
    elsif activity == 4
      options[:sent]  ||= 'Not received yet'
      options[:received] ||= 'Received'
      if status == "5"
        content_tag(:span, options[:sent], :class => 'label label-primary')
      elsif status == "6"
        content_tag(:span, options[:received], :class => 'label label-success')
      elsif status == '0'
        content_tag(:span, 'Incomplete', :class => 'label label-danger')
      end
    end
  end

  def transfer_item_status(activity,stock_transfer,status,options={})
    if activity == 2
      notification_flag = 0;
      stock_transfer.stock_transfer_meta.map{ |e| 
        notification_flag = 1 if e.quantity_transfered != e.quantity_received
      }
      options[:partial] ||= 'Partially stock received'
      if status == "100" &&  notification_flag == 1
        content_tag(:span, options[:partial], :class => 'label label-warning margin-l-100')
      end
    end    
  end

  def transfer_type(activity,options={})
    if activity == 2
      options[:trans_to_oth]  ||= 'Interbranch - Store'
      content_tag(:strong, options[:trans_to_oth])
    elsif activity == 3
      options[:trans_to_ktc]  ||= 'Store - Production center'
      content_tag(:strong, options[:trans_to_ktc])
    elsif activity == 4
      options[:trans_to_own]  ||= 'Intrabranch - Store'
      content_tag(:strong, options[:trans_to_own])
    end
  end

  def can_receive_transfer_items? activity,_current_store_id,_from_store_id,_to_store_id,_status
    if activity == 2 # Condition for store to store transfer
      return ((_status == "30" && _to_store_id == _current_store_id) || (_status == "60" && _from_store_id == _current_store_id)) ? true : false
    elsif activity == 3 # Condition for store to kitchen transfer
      return (_status == "1" && _to_store_id == _current_store_id) ? true : false
    elsif activity == 4 # Condition for store to own transfer
      # return ((_status == "5" && _to_store_id == _current_store_id) || _status == "6") ? true : false
      return (_status == "6" || (_status == "5" && _to_store_id != _current_store_id)) ? false : true
    end
  end

  # => Function to show inputs fields in "stock_transfer > show" to receive shipment
  def get_receiving_input_tags(activity,_current_store_id,_from_store_id,_to_store_id,_status,product_id,qty,product_unit,_transaction_id)
    if activity == 2 # COndition for store to store transfer
      if (_status == "30" && _to_store_id == _current_store_id) || (_status == "60" && _from_store_id == _current_store_id)
        content_tag :div, :class => "input-group" do
          text_field_tag("quantity_#{product_id}",qty, :required=> true, :class => 'form-control numeric-only') +
          content_tag(:div, product_unit, class: "input-group-addon")
        end
      elsif _status == "100"
        stock_entry = (Stock.set_transaction(_transaction_id).set_store(_to_store_id).get_product(product_id).first)
        content_tag(:span, "#{stock_entry.stock_credit} #{product_unit}", :class => 'label label-success') +
        content_tag(:span, "(Price: #{currency}. #{stock_entry.price})")
      elsif _status == "90"
        _product_recvd = (Stock.set_transaction(_transaction_id).set_store(_from_store_id).get_product(product_id).last).stock_credit
        content_tag(:span, "#{_product_recvd} #{product_unit}", :class => 'label label-danger')
      else
        content_tag(:span, 'Not received yet', :class => 'label label-warning')
      end
    elsif activity == 3 # COndition for store to kitchen transfer
      if _status == "1" && _to_store_id == _current_store_id
        content_tag :div, :class => "input-group" do
          text_field_tag("quantity_#{product_id}",qty, :required=> true, :class => 'form-control numeric-only') +
          content_tag(:div, product_unit, class: "input-group-addon")
        end
      elsif _status == "2"
        _product_recvd = (Stock.set_transaction(_transaction_id).set_store(_to_store_id).get_product(product_id).first).stock_credit
        content_tag(:span, "#{_product_recvd} #{product_unit}", :class => 'label label-success')
      else
        content_tag(:span, 'Not received yet', :class => 'label label-warning')
      end
    elsif activity == 4
      if _status == "5" && _to_store_id == _current_store_id
        content_tag :div, :class => "input-group" do
          text_field_tag("quantity_#{product_id}",qty, :required=> true, :class => 'form-control numeric-only') +
          content_tag(:div, product_unit, class: "input-group-addon")
        end
      elsif _status == "6"
        _product_recvd = (Stock.set_transaction(_transaction_id).set_store(_to_store_id).get_product(product_id).first).stock_credit
        content_tag(:span, "#{_product_recvd} #{product_unit}", :class => 'label label-success')
      else
        content_tag(:span, 'Not received yet', :class => 'label label-warning')
      end
    end
  end

  def get_transfer_receiving_hidden_fields(activity_id,status)
    if (activity_id == 2 && status == "30")
      hidden_field_tag("update_type",'receive_shipment') +
      hidden_field_tag("stock_transfer[status]",'100') +
      hidden_field_tag("status_desc",'Shipment products has been successfully received')
    elsif (activity_id == 2 && status == "60")
      hidden_field_tag("update_type",'receive_return_shipment') +
      hidden_field_tag("stock_transfer[status]",'90') +
      hidden_field_tag("status_desc",'Return shipment products has been successfully received')
    elsif (activity_id == 3 && status == "1")
      hidden_field_tag("update_type",'receive_shipment') +
      hidden_field_tag("stock_transfer[status]",'2') +
      hidden_field_tag("status_desc",'Products from store successfully received in production center')
    elsif (activity_id == 4 && status == "5")
      hidden_field_tag("update_type",'receive_shipment') +
      hidden_field_tag("stock_transfer[status]",'6') +
      hidden_field_tag("status_desc",'Shipment products has been successfully received')
    end
  end

  def get_receiving_button_tag(activity,_current_store_id,_from_store_id,_to_store_id,_status)
    if activity == 2
      if (_status == "30" && _to_store_id == _current_store_id)
        content_tag(:button, 'Receive products and add to stock', :type => "submit", :class=> 'm-btn green waves-effect waves-light', :name=>'stock_transfer[status]', :value=>'100')
      elsif (_status == "60" && _from_store_id == _current_store_id)
        content_tag(:button, 'Receive products and add to stock', :type => "submit", :class=> 'm-btn green waves-effect waves-light', :name=>'stock_transfer[status]', :value=>'90')
      end
    elsif activity == 3
      if (_status == "1" && _to_store_id == _current_store_id)
        content_tag(:button, 'Receive products and add to stock', :type => "submit", :class=> 'm-btn green waves-effect waves-light', :name=>'stock_transfer[status]', :value=>'2')
      end
    elsif activity == 4
      if (_status == "5" && _to_store_id == _current_store_id)
        content_tag(:button, 'Receive products and add to stock', :type => "submit", :class=> 'm-btn green waves-effect waves-light', :name=>'stock_transfer[status]', :value=>'6')
      end
    end
  end

  def get_return_button_tag(activity,_current_store_id,_to_store_id,_status)
    if activity == 2
      if _status == "30" && _to_store_id == _current_store_id
        content_tag(:button, 'Return shipment products', :type => "submit", :class=> 'm-btn red waves-effect waves-light', :name=>'stock_transfer[status]', :value=>'50')
      end
    end
  end

  def can_audit_item(activity, store_id, stock_transfer, status, current_store_id)
    if activity == 2 && current_store_id == store_id
      notification_flag = 0;
      stock_transfer.stock_transfer_meta.map{ |e| 
        notification_flag = 1 if e.quantity_transfered != e.quantity_received && e.status == "partially_receved"
      }
      if status == "100"
        return (notification_flag == 1) ? true : false
      end  
    end
  end

  # def render_transfer_action_link(activity,current_store,from_store,to_store,status)
  def link_to_transfer_action(store, transfer)
    if transfer.activity_id == 2
      if transfer.status == '0'
        link_to 'View', "#{store_stock_transfer_steps_path(store, transfer)}/manage_products", :class=>"m-btn blue float-r"
      elsif transfer.status == "30" && transfer.secondary_store_id == store.id
        link_to 'Receive shipment', store_stock_transfer_path(store, transfer), :class=>"m-btn blue float-r"
      elsif transfer.status == "60" && transfer.primary_store_id == store.id
        link_to 'Receive return shipment', store_stock_transfer_path(store, transfer), :class=>"m-btn blue float-r"
      else
        link_to 'View', store_stock_transfer_path(store, transfer), :class=>"m-btn blue float-r"
      end
    elsif transfer.activity_id == 3
      if transfer.status == '0'
        link_to 'View', "#{store_stock_transfer_steps_path(store, transfer)}/manage_products", :class=>"m-btn blue float-r"
      elsif transfer.status == "1" && transfer.secondary_store_id == store.id
        link_to 'Receive shipment', store_stock_transfer_path(store, transfer), :class=>"m-btn blue float-r"
      else
        link_to 'View', store_stock_transfer_path(store, transfer), :class=>"m-btn blue float-r"
      end
    elsif transfer.activity_id == 4
      if transfer.status == '0'
        link_to 'View', "#{store_stock_transfer_steps_path(store, transfer)}/manage_products", :class=>"m-btn blue float-r"
      elsif transfer.status == "5" && transfer.secondary_store_id == store.id
        link_to 'Receive shipment', store_stock_transfer_path(store, transfer), :class=>"m-btn blue float-r"
      else
        link_to 'View', store_stock_transfer_path(store, transfer), :class=>"m-btn blue float-r"
      end
    end
  end

  def transfer_items_received? object
    if object.activity_id == 2 # Condition for store to store transfer
      return ((object.status == "100")  || (object.status == "90")) ? true : false
    elsif object.activity_id == 3 # Condition for store to kitchen transfer
      return (object.status == "2") ? true : false
    elsif object.activity_id == 4 # Condition for store to own transfer
      return (object.status == "6") ? true : false
    end
  end

  def production_status_class(status)
    if status == '1'
      return 'module_primary'
    elsif status == '2'
      return 'module_active'
    end
  end

  def production_status_tag(status,options={})
    options[:processing]  ||= 'New Production'
    options[:procured] ||= 'Production complete'
    options[:start] ||= 'Production started'
    options[:halt] ||= 'Production Halted'
    if status == "1"
      content_tag(:span, options[:processing], :class => 'label label-primary')
    elsif status == "2"
      content_tag(:span, options[:procured], :class => 'label label-success')
    elsif status == '3'
      content_tag(:span, options[:start], :class => 'label label-warning')
    else
      content_tag(:span, options[:halt], :class => 'label label-danger')
    end
  end

  def get_production_action_button_text(status)
    if status == "1"
      return "Start & approve production"
    elsif status == "2" or status == "3"
      return "Finish & approve Production"
    elsif  status == "4"
      return "Resume Production"
    end
  end

  def get_production_button_tag(_status)
    if _status == "2"
      content_tag(:button, "Add to stock", :type => "submit", :class => "m-btn green", :id => "add_to_stock_production_btn")

      # content_tag(:button, 'Finish production & add to stock', :type => "submit", :class=> 'm-btn green')
    else
      content_tag(:button, 'Finish production', :type => "submit", :class=> 'm-btn green', :id => "finish_production_btn")
    end
  end

  def get_production_button(_is_stock_added)
    if _is_stock_added == 0
      content_tag(:button, 'Finish production', :type => "submit", :class=> 'm-btn green')
    elsif _is_stock_added == 1
      content_tag(:button, "Add to stock", :type => "submit", :class => "m-btn green")
    end
  end

  # => Active or inactive css class for stock_purchase indexing
  def audit_status_class(status)
    if status == '1'
      return 'module_primary'
    elsif status == '2'
      return 'module_active'
    elsif status == '3'
      return 'module_alert'
    end
  end

  def audit_status_tag(status,options={})
    options[:not_approved]  ||= 'Not approved yet'
    options[:approved] ||= 'Approved'
    options[:rejected] ||= 'Rejected'

    if status == "1"
      content_tag(:span, options[:not_approved], :class => 'blue m-label')
    elsif status == "2"
      content_tag(:span, options[:approved], :class => 'green m-label')
    elsif status == "3"
      content_tag(:span, options[:rejected], :class => 'red m-label')
    end
  end

  def audit_status(status)
    if status == "1"
      return "Not approved yet"
    elsif status == "2"
      return "Approved"
    elsif status == "3"
      return "Rejected"
    end
  end

  def get_audited_quantity(store_id, product_id, stock_transaction_id)
    _stock = Stock.set_store(store_id).get_product(product_id).set_transaction(stock_transaction_id).first
    return _stock
  end

  def invoice_name(stock_transfer)
    invoice_name = "TRANS-IN-#{stock_transfer.id}-#{stock_transfer.created_at.strftime('%Y%m%d')}"
  end

  def production_audit_status_class(status)
    if status == '2'
      return 'module_primary'
    elsif status == '3'
      return 'module_active'
    elsif status == '4'
      return 'module_alert'
    end
  end

  def production_audit_status_tag(status,options={})
    options[:not_approved]  ||= 'Not approved yet'
    options[:approved] ||= 'Approved'
    options[:rejected] ||= 'Rejected'

    if status == "2"
      content_tag(:span, options[:not_approved], :class => 'label label-primary')
    elsif status == "3"
      content_tag(:span, options[:approved], :class => 'label label-success')
    elsif status == "4"
      content_tag(:span, options[:rejected], :class => 'label label-danger')
    end
  end

  def get_product_stock_data(store, product, from_date, to_date)
    _arr = Stock.get_stock_report(store, product, from_date, to_date)
  end

  def get_product_opening_closing(store, product, from_date, to_date)
    _arr = Stock.get_opening_closing(store, product, from_date, to_date)
  end

  def get_store_stock_data(store, from_date, to_date)
    _arr = Stock.get_store_stock_report(store, from_date, to_date)
  end

  def get_input_taxes(product_id,unit_id,uid='')
    uid = uid.present? ? uid : 1
    _product = Product.find(product_id)
    _unit_product = _product.unit_products.by_unit(unit_id)
    select_tag "tax_classes_#{product_id}", options_for_select(_unit_product.first.tax_group.tax_classes.map{ |tc| ["#{tc.name} @#{tc.ammount}", "#{tc.id}__#{tc.ammount}__#{tc.name}__#{tc.amount_type}"] }), { prompt: "Select a tax class", :class=>"form-control tax_class_list", "data-product-id"=>product_id, "data-uid"=>uid } if _unit_product.present?
  end

  def get_estimated_price(product_id, store_id, quantity)
    price = Stock.estimate_stock_consumption_price(store_id, product_id, quantity)
    price.round(2)
  end

  def get_transfer_action_button_text(activity,current_store,from_store,to_store,status)
    if activity == 2
      if status == "30" && to_store == current_store
        return "Receive shipment"
      elsif status == "60" && from_store == current_store
        return "Receive return shipment"
      else
        return "Details"
      end
    elsif activity == 3
      if status == "1" && to_store == current_store
        return "Receive products"
      else
        return "Details"
      end
    elsif activity == 4
      if status == "5" && to_store == current_store
        return "Receive products"
      else
        return "Details"
      end
    end
  end
  def get_product_name(bin_id)
    bin_product = BinProduct.where("bin_id=?",bin_id).first
    if bin_product.present?
      bin_product=bin_product.product.name
      bin_product
    else
      puts "Product not found"
    end
  end
  def stock_transfer_unit_name(product_transaction_unit_id)
    product_unit = ProductTransactionUnit.find(product_transaction_unit_id)
    return product_unit.product_unit_name
  end
  def get_product_multiplier(product_transaction_unit_id)
    product_unit = ProductTransactionUnit.find(product_transaction_unit_id)
    return product_unit.basic_unit_multiplier
  end
  def get_unit_basic_multiplier(basic_unit_id)
    product_unit = ProductUnit.where("product_basic_unit_id=?",basic_unit_id).first
    return product_unit.multiplier
  end

  def get_product_units(basic_unit_id)
    product_units = ProductUnit.where("product_basic_unit_id=?",basic_unit_id)
    if product_units.present?
       return product_units
    end
  end
  def has_po_order_send?(po_id)
    if StockPurchase.where("purchase_order_id=?",po_id).present?
      return true
    else
      return false
    end
  end
  
  def has_po_order_cancelled?(po_id)
    return PurchaseOrder.find(po_id).status == 'cancelled' ? true : false
  end

end