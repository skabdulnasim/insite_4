class Api::RestapiController < ApplicationController
  require 'json'
  before_filter :set_timerange, only: [:quick_reports]

  def index
    @units = Unit.all
    respond_to do |format|
      format.json { render :json => @units }
    end
  end

  def get_orders
    _product_details = {}
    _order_details = []
    params[:order_ids].each do |order_id|
      order = Order.find(order_id)
      order_details = order.order_details
      if order_details.present?
        order_details.each do |order_detail|
          if _product_details.has_key? order_detail.product_id
            _product_details[order_detail.product_id] += order_detail.quantity
            _product_details[:title] = "#{order_detail.product_name}-22Pc"
            _product_details[:product_id] = order_detail.product_id
            _product_details[:basic_unit] = order_detail.product.basic_unit
          else
            _product_details[order_detail.product_id] = order_detail.quantity
            _product_details[:title] = "#{order_detail.product_name}-22Pc"
            _product_details[:product_id] = order_detail.product_id
            _product_details[:basic_unit] = order_detail.product.basic_unit
          end
        end
        _product_details[:start] = '2018-07-16'
        _product_details[:end] = '2018-07-16'
        #_product_details[:allDay] = false
        _product_details[:recurring] = false
        _order_details.push _product_details
      end
    end  
    respond_to do |format|
      format.json{render :json => _order_details}
    end
  end

  #********************* Get user details by Email ID (New) *********************#
  def get_user_by_email

    if params[:key_phrase].present?
      # _user = User.find(:first, :conditions => ["key_phrase = :key_phrase",{key_phrase: params[:key_phrase]}]) # rails 4 comment
      _user = User.where(:key_phrase => params[:key_phrase]).first
    else
      _userdata = User.where(:email => params[:email_id]).first
      _valid = _userdata.valid_password?(params[:password]) unless _userdata.nil?
      if _valid.present?
        _user = _userdata
      end
    end
    _return_arr = Array.new
    _arr = {}
    if _user.present?
      #_user = User.find(:first, :conditions => ["email = ?", params[:email_id]])
      _primary_store = Store.unit_stores(_user.unit_id).physical.primary.first
      _all_vans = Vehicle.unit_vehicles(_user.unit_id)
      @capabilities = _user.role.capabilities
      if @capabilities.present?
        _auths = JSON.parse(@capabilities)
        _capa = Array.new
        _hash = {}
        _auths.each do |au|
          _result = au.split(", ")
          if _hash.has_key?(_result[1])
            _inarr = _hash[_result[1]]
            _inarr.push(_result[0])
            _hash[_result[1]] = _inarr
          else
            _inarr = Array.new
            _inarr.push(_result[0])
            _hash[_result[1]]=_inarr
          end
        end #end of capabilities foreach
        @capabilities = _hash
      else
        @capabilities = {}
      end
      _arr[:user_id] = _user.id
      _arr[:email] = _user.email
      _arr[:auth_token] = _user.auth_token
      _arr[:unit_id] = _user.unit_id
      _arr[:unit_name] = _user.unit.unit_name
      _arr[:last_bill_serial_number] = Bill.last_serial_number(_user.unit_id,params[:device_id])
      _arr[:store_id] = _primary_store.id unless _primary_store.nil?
      _arr[:store_name] = _primary_store.name unless _primary_store.nil?
      _arr[:delivery_vans] = _all_vans
      _arr[:currency] = Account.find_by_subdomain(request.subdomain).currency.presence || "Rs"
      _arr[:capabilities] = @capabilities
      _arr[:push_server_ip] = "#{FAYE_SERVER_IP}"
      _return_arr.push(_arr)
      respond_to do |format|
        format.json { render :json => _return_arr  }
      end
    else
      _arr[:error] = "The email or password you entered is incorrect, please try again."
      _return_arr.push(_arr)
      respond_to do |format|
        format.json { render :json => _return_arr  }
      end
    end
  end

  def upload_media
    begin
      timestamp = Time.now.to_i
      file_name = timestamp.to_s+"-"+params[:media_file].original_filename
      img = params[:media_file]
      File.open(Rails.root.join('public','uploads','attachments',file_name),'wb') do |file|
        file.write(img.read)
      end
      respond_to do |format|
        format.json { render :json => {:success=>"Media file successfully uploaded.", :media=>file_name}}
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render :json => {:error=>"Error occured while uploading media file."}}
      end
    end
  end

  def quick_reports
    _sales_today    = Bill.unit_bills(params[:unit_id]).check_bill_date_range(@today_from_datetime,@today_to_datetime).sum(:grand_total)
    _discount_today = Bill.unit_bills(params[:unit_id]).check_bill_date_range(@today_from_datetime,@today_to_datetime).sum(:discount)
    _discount_total = Bill.unit_bills(params[:unit_id]).sum(:discount)
    _void_bill      = Bill.unit_bills(params[:unit_id]).check_bill_date_range(@today_from_datetime,@today_to_datetime).set_status('void').count
    _nc_bill        = Bill.unit_bills(params[:unit_id]).check_bill_date_range(@today_from_datetime,@today_to_datetime).set_status('no_charge').count
    settlement_data = Bill.get_unit_settlement_data(params[:unit_id],@today_from_datetime,@today_to_datetime)
    respond_to do |format|
      format.json { render :json => { :sales_today    => _sales_today,
                                      :discount_today => _discount_today,
                                      :total_discount => _discount_total,
                                      :void_bill      => _void_bill,
                                      :nc_bill        => _nc_bill,
                                      :card_sale      => settlement_data[:card_sale],
                                      :cash_sale      => settlement_data[:cash_sale]
                                      }}
    end
  end

  def get_resources
    begin
      _date = params[:reservation_date].present? ? params[:reservation_date] : Date.today
      availablity = Availability.distinct_resource_by_date(_date)
      _arr = Array.new
      availablity.each do |available|
        _hash = {}
        _hash[:resource_id]    = available.resource_id
        _hash[:resource_name]  = available.resource.name
        _arr.push _hash
      end
      respond_to do |format|
        format.json{render :json => _arr}
      end
    rescue Exception => e
      respond_to do |format|
        format.json{render :json => {:error=>e.message}}
      end
    end
  end

  def get_slots
    begin
      availablity = Availability.by_date(params[:reservation_date]).by_resource(params[:resource_id])
      _arr = Array.new
      availablity.each do |available|
        customers = Reservation.get_customers(params[:reservation_date],params[:resource_id],available.slot_id)
        customer_array = Array.new
        customers.each do |customer|
          customer_hash = {}
          customer_hash[:customer_name] = customer.customer.profile.firstname+" "+customer.customer.profile.lastname
          customer_hash[:mobile_no] = customer.customer.mobile_no
          customer_array.push customer_hash[:customer_name]
        end
        _hash = {}
        _hash[:available_date] = available.available_date
        _hash[:resource_id]    = available.resource_id
        _hash[:slot_id]        = available.slot_id
        _hash[:slot_name]      = available.slot.title
        _hash[:start_time]     = available.slot.start_time.strftime("%I:%M%p")
        _hash[:end_time]       = available.slot.end_time.strftime("%I:%M%p")
        _hash[:duration]       = available.slot.duration
        _hash[:customers]      = customer_array
        _arr.push _hash
      end
      respond_to do |format|
        format.json{render :json => _arr}
      end
    rescue Exception => e
      respond_to do |format|
        format.json{render :json => {:error=>e.message}}
      end
    end
  end

  def get_reservations
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    _today = Date.today
    _date = params[:date].present? ? params[:date] : _today
    _reservations = []
    if params[:resource].present?
      _reservations = Reservation.by_resource(params[:resource]).by_date(_date)
    else
      _reservations = Reservation.all
    end
    _reservation = []
    _reservations.each do |res|
      _hash = {}
      _hash[:id] = res.id
      _resources = res.reservation_details.map{|res_dtls| res_dtls.resource.name }
      _resources = _resources.join(",")
      _hash[:title] = _resources
      _hash[:description] = "Customer : #{res.customer.profile.firstname} #{res.customer.profile.lastname}"
      if res.start_date.present?
        _hash[:start] = "#{res.start_date.strftime("%Y-%m-%d")}T#{res.start_date.strftime("%I:%M")}:00Z"
        _hash[:end] = "#{res.end_date.strftime("%Y-%m-%d")}T#{res.end_date.strftime("%I:%M")}:00Z"
      else  
        _hash[:start] = "#{res.reservation_date}T#{res.start_time.strftime("%I:%M")}:00Z"
        _hash[:end] = "#{res.reservation_date}T#{res.end_time.strftime("%I:%M")}:00Z"
      end  
      _hash[:allDay] = false
      _hash[:recurring] = false
      _reservation.push _hash
    end
    respond_to do |format|
      format.json{render :json => _reservation}
    end
  end

  def get_available_slot
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    _date = params[:date].present? ? params[:date] : _today
    _reservations = Reservation.by_resource(params[:resource]).by_date(_date).by_unit(_unit_id).by_slot(params[:slot_id]).order("end_time DESC")
    _reservation = {}
    if _reservations.blank?
      slot = Slot.find(params[:slot_id])
      _reservation[:start_time] = slot.start_time.strftime("%H:%M:%S")
      _reservation[:end_time] = slot.end_time.strftime("%H:%M:%S")
      _reservation[:next_start_time] = slot.start_time.strftime("%H:%M:%S")
      _reservation[:next_end_time] = (slot.start_time + slot.duration*60).strftime("%H:%M:%S")
      _reservation[:duration] = slot.duration
    else
      res = _reservations.first
      _reservation[:start_time] = res.start_time.strftime("%H:%M:%S")
      _reservation[:end_time] = res.end_time.strftime("%H:%M:%S")
      _reservation[:next_start_time] = res.end_time.strftime("%H:%M:%S")
      _reservation[:next_end_time] = (res.end_time + res.slot.duration*60).strftime("%H:%M:%S")
      _reservation[:duration] = res.slot.duration
    end
    respond_to do |format|
      format.json{render :json => _reservation}
    end
  end

  #********************* Get All stores *********************#
  def get_store_data
    _store = Store.unit_stores(params[:unit_id]).physical.primary.first
    _secondary_stores = Store.where("id != ?", _store.id).primary.physical
    _all_vans = Vehicle.unit_vehicles(params[:unit_id])
    respond_to do |format|
      format.json { render :json =>  {:store=>_store,:other_stores=>_secondary_stores,:delivery_vans=>_all_vans} }
    end
  end
  #********************* Function to get stock of all products for a store (New)*********************#
  def get_all_product_stocks
    _store_id = params[:store_id]
    _products = Product.get_all

    _products_array = Array.new
    _products.each do |pro|
      _arr = {}
      _arr[:id] = pro.id
      _arr[:name] = pro.name
      _arr[:image] = pro.product_image
      _arr[:current_stock] = StockUpdate.current_stock(_store_id,pro.id)
      _arr[:product_unit] = pro.basic_unit
      _arr[:product_category] = pro.category.id
      _arr[:product_parent_category] = pro.category.parent ? pro.category.parent : 0
      _arr[:business_type] = pro.business_type
      _products_array.push(_arr)
    end
    _products_json = JSON.generate(_products_array)
    respond_to do |format|
      format.json { render :json => _products_json  }
    end
  end

  def get_store_stocks
    @stores = Store.unit_stores(params[:unit_id])
    respond_to do |format|
      format.json { render json: @stores.to_json(:include => :stocks)}
    end
  end

  ############# Function to transfer products to other stores #############
  # => @params user_id, expected_delivery_date
  def initiaize_product_transfer
    _attrs = JSON.parse(params[:transfer_attributes])
    _err_possibility = 0
    _attrs['products'].each do |rs|
      _err_possibility = _err_possibility + check_transfer_possibility(_attrs['from_store_id'],rs['product_id'],rs['amount'])
    end
    if _err_possibility > 0
      respond_to do |format|
        format.json { render :json => {:error=>_err_possibility.to_s+" product don't have enough stock for this transfer"} }
      end
    else
      _status_log = StockTransfer.generate_status_json(nil,"10","Shipment has been packed and ready for shipment",_attrs['user_id'])
      _stock_transfer = StockTransfer.initiate_transfer(_attrs['from_store_id'],_attrs['to_store_id'],_attrs['vehicle_id'],2,"10",_status_log,nil,_attrs['expected_delivery_date'])
      _new_invoice = StockTransferInvoice.create_invoice(_stock_transfer.id,nil) #generating invoice
      _invoice_total_price = 0
      _attrs['products'].each do |product|
        _total_qty, _total_price = 0, 0
        _product_stock_counter = product['amount']
        _transfer_options = Stock.product_debit_options(_attrs['from_store_id'], product['product_id'])
        _transfer_options.each do |ta|
          if _product_stock_counter.to_f >= ta.available_stock.to_f
            _total_price = _total_price + (Stock.get_stock_price(ta.id,ta.available_stock.to_f)).to_f
            _total_qty = _total_qty + ta.available_stock.to_f
            Stock.consume_stock_debit(ta.id,ta.available_stock.to_f,nil,"Transfer Debit") #Then debit from stocks
            _product_stock_counter = _product_stock_counter - ta.available_stock.to_f
          elsif _product_stock_counter > 0
            _total_price = _total_price + (Stock.get_stock_price(ta.id,_product_stock_counter.to_f)).to_f
            _total_qty = _total_qty + _product_stock_counter.to_f
            Stock.consume_stock_debit(ta.id,_product_stock_counter.to_f,nil,"Transfer Debit") #Then debit from stocks
            _product_stock_counter = 0
          end
        end
        _stock = Stock.save_stock(product['product_id'],_attrs['from_store_id'],_total_price,0,_stock_transfer.id,'stock_transfer',0,_total_qty,nil,nil,nil)
        _invoice_meta = StockTransferInvoiceMetum.create_invoice_meta(_total_price,product['product_id'],_total_qty,_new_invoice.id)
        _invoice_total_price = _invoice_total_price + _total_price
      end
      _new_invoice.update_attribute(:price, _invoice_total_price)
      respond_to do |format|
        format.json { render :json => _stock_transfer}
      end
    end
  end

  ############# Function to get all stocks pending for receipt (New) #############
  def get_store_delivering_stocks
    @store = Store.find(params[:store_id])
    _pending_deliveries = @store.stock_credit_transfers.delivering.desc_order

    _return_arr = Array.new
    _pending_deliveries.each do |pd|
      #puts pd.stock_order_id
      _pd_arr = {}
      _pd_arr[:stock_transaction_id] = pd.id
      _stock_entries = pd.stocks.set_store(pd.primary_store_id).type_debit
      _pro_array = Array.new
      _stock_entries.each do |se|
        _pd_arr['date'] = se.updated_at
        _arr={}
        _arr[:serial_no] = se.id
        _arr[:product_id] = se.product_id
        _arr[:product_name] = se.product.name
        _arr[:product_unit] = se.product.basic_unit
        _arr[:stock] = se.stock_debit
        _arr[:created_at] = se.created_at
        _arr[:updated_at] = se.updated_at
        _pro_array.push(_arr)
      end
      _from_store = Store.find(pd.primary_store_id)
      _pd_arr['from_store'] = _from_store.name
      _pd_arr['vehicle_id'] = pd.vehicle_id
      _pd_arr['products'] = _pro_array
      _size = (_return_arr.size)+1
      _return_arr.push(_pd_arr)
    end
    respond_to do |format|
      format.json { render :json => _return_arr  }
    end
  end

  ############# Function to get all stocks pending for receipt (New) #############
  def recieve_shipment_products
    received_products = JSON.parse(params[:received_stocks])
    @stock_transfer = StockTransfer.find(params[:stock_transaction_id])
    @status_log = StockTransfer.generate_status_json(@stock_transfer.id,'100','Shipment items have been received successfully (App)',params[:user_id])
    @store = Store.find(@stock_transfer.secondary_store_id)
    received_products.each do |stk|
      _stock_details = Stock.set_transaction(@stock_transfer.id).get_product(stk['product_id']).first
      _recvd_stock = Stock.save_stock(stk['product_id'],@stock_transfer.secondary_store_id,_stock_details.price,stk['recv_stock'],@stock_transfer.id,'stock_transfer',stk['recv_stock'],0,nil,nil)
    end
    @stock_transfer.update_attribute(:status,'100')
    @stock_transfer.update_attribute(:status_log,@status_log) #Updating status for product transfers
    respond_to do |format|
      format.json { render :json => @stock_transfer }
    end
  end

  ############# Function to get all po pendings #############
  def get_store_pending_pos
    @store = Store.find(params[:store_id])
    _pending_po = @store.stock_purchases.pending_pos.desc_order
    #_pending_po = PurchaseOrderStock.find(:all, :select => 'DISTINCT po_serial_no',:conditions=>["store_id =? and status=?",_store_id,"1" ])
    _return_arr = Array.new
    _pending_po.each do |pd|
      _pd_arr = {}
      _pd_arr['stock_transaction_id'] = pd.id
      _pd_arr['date'] = pd.created_at
      _pro_array = Array.new
      _po_products = pd.purchase_order.purchase_order_metum
      _po_products.each do |se|

        _arr={}
        _arr[:serial_no] = se.id
        _arr[:product_id] = se.product_id
        _arr[:product_name] = se.product.name
        _arr[:order_stock] = se.product_amount
        _arr[:created_at] = se.created_at
        _pro_array.push(_arr)
      end
      _pd_arr['purchase_order_id'] = pd.purchase_order_id
      _pd_arr['vendor_id'] = pd.purchase_order.vendor.name
      _pd_arr['products'] = _pro_array
      _size = (_return_arr.size)+1
      _return_arr.push(_pd_arr)
    end
    respond_to do |format|
      format.json { render :json => _return_arr  }
    end
  end

  ############# Function to get all po pending for receipt #############
  def receive_po_items
    begin
      received_stock = JSON.parse(params[:received_pos])
      _stock_purchase = StockPurchase.find(received_stock['stock_transaction_id'])
      raise 'Products in this purchase order already received.' if _stock_purchase.status == "2"
      ActiveRecord::Base.transaction do # Protective transaction block
        received_stock['products'].each do |rs|
          _recvd_stock = Stock.save_stock(rs['product_id'],_stock_purchase.store_id,rs['price'],rs['recv_stock'],_stock_purchase.id,'stock_purchase',rs['recv_stock'],0,rs['expiry_date'],nil,nil)
        end
        _stock_purchase.update_attribute(:status, "2")
        _stock_purchase.update_attribute(:attachment, params[:invoice_image])
      end
      respond_to do |format|
        format.json { render :json => _stock_purchase  }
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render :json => {:error => e.message}  }
      end
    end
  end

  ######### Delivery VAN related API #########

  ######### Get all shipments (Pickup, shipped, delivering) ** New ** #########
  def get_pickup_packages
    @vehicle = Vehicle.find(params[:vehicle_id])
    _return_arr = Array.new
    _processing_shipments = @vehicle.stock_transfers.desc_order.set_transfer_status(params[:status])
    _processing_shipments.each do |pd|
      _pd_arr = {}
      _pd_arr[:stock_transaction_id] = pd.id
      _stock_entries = pd.stocks.set_store(pd.primary_store_id)
      _pro_array = Array.new
      _stock_entries.each do |se|
        _pd_arr['date'] = se.updated_at
        _arr={}
        _arr[:serial_no] = se.id
        _arr[:product_id] = se.product_id
        _arr[:product_name] = se.product.name
        _arr[:product_unit] = se.product.basic_unit
        _arr[:product_amount] = se.stock_debit
        _arr[:created_at] = se.created_at
        _arr[:updated_at] = se.updated_at
        _pro_array.push(_arr)
      end
      _pd_arr['from_store'] = pd.from_store
      _pd_arr['to_store'] = pd.to_store
      _pd_arr['products'] = _pro_array
      _size = (_return_arr.size)+1
      _return_arr.push(_pd_arr)
    end
    respond_to do |format|
      format.json { render :json => _return_arr  }
    end
  end

  ########## Update Shipment status (New) ############
  def update_shipment_status
    _stock_transfer = StockTransfer.find(params[:stock_transaction_id])
    _status_log = StockTransfer.generate_status_json(_stock_transfer.id,params[:status],params[:status_long_desc],params[:user_id])
    _stock_transfer.update_attribute(:status, params[:status])
    _stock_transfer.update_attribute(:status_log, _status_log)
    _stock_transfer_updated = StockTransfer.find(_stock_transfer.id)
    respond_to do |format|
      format.json { render :json => _stock_transfer_updated  }
    end
  end

  # Stock Audit APIs
  ##################################################################
  def get_stock_audit_debit_info
    _products = JSON.parse(params[:products])
    _pro_array = Array.new
    _products.each do |pro|
      _arr={}
      _arr[:product_id] = pro['product_id']
      _arr[:current_stock] = StockUpdate.current_stock(params[:store_id], pro['product_id'])
      _arr[:debit_options] =Stock.product_debit_options(params[:store_id], pro['product_id'])
      _pro_array.push(_arr)
    end
    respond_to do |format|
      format.json { render :json => _pro_array  }
    end
  end

  def initiate_stock_audit
    begin
      puts params
      products_arr = JSON.parse(params[:products], :symbolize_names => true)
      raise 'No products selected for audit.' if products_arr.nil?
      ActiveRecord::Base.transaction do # Protective transaction block
        StockAudit.initiate_audit_procedure(params[:store_id],products_arr, params[:user_id],params[:business_type])
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render :json => {:error=> e.message}  }
      end
    else
      respond_to do |format|
        format.json { render :json => {:success=> "Stock audit was successfully initiated."}  }
      end
    end
  end

  def adsr_data_exposer
    begin
      raise "email required" unless params[:email].present?
      user       = User.by_email(params[:email]).first
      unit       = user.unit
      unit_detail_options ||= unit.unit_detail.options if unit.unit_detail.present?
      _closing_time = unit_detail_options.present? ? unit_detail_options[:day_closing_time].to_i.hours : (0).to_i.hours

      from_date  = (params[:from_date] || Date.today.to_s).to_date.beginning_of_day+_closing_time
      to_date    = (params[:to_date]   || from_date).to_date.end_of_day+_closing_time
      raise "Don't have permission to access" unless user.present?


      _bill_data  = Bill.unit_bills(unit.id).by_recorded_at from_date,to_date
      respond_to do |format|
        format.json {render :json => _bill_data.map{|data| {:RECORD_TYPE=>"CLARIFICATION REQUIRED",
                                                            :POS_TILL=>"CLARIFICATION REQUIRED",
                                                            :SHIFT_NO=>"TBD",
                                                            :RECEIPT_NO=>data.id,
                                                            :BILL_SERIAL_NUMBER => data.serial_no,
                                                            :TIMESTAMP=>data.recorded_at,
                                                            :INV_AMT=>data.bill_amount,
                                                            :TAX_AMT=>data.tax_amount,
                                                            :DIS_AMT=>data.discount,
                                                            :NET_AMT=>data.grand_total,
                                                            :TRANSACTION_STATUS=>data.status,
                                                            :TAX_DETAILS=> data.bill_tax_amounts.map{|entry|{
                                                                :NAME=>entry.tax_class.name,
                                                                :RATE=>entry.tax_class.ammount,
                                                                :AMOUNT=>entry.tax_amount,
                                                                :TYPE=>entry.tax_class.tax_type
                                                            }},
                                                            #:CUST_NAME=>"?"
                                                            :UNIT_ID=>data.unit_id,

                                                            :ITEMS=>data.orders.map {|order| order.order_details.map{|order_detail|{
                                                              #:RECEIPT_NO=>"ALL READY MENTIONED WILL BE REMOVED",
                                                              :TIMESTAMP=>order_detail.created_at,
                                                              :RECORD_TYPE=>"CLARIFICATION REQUIRED",
                                                              :ITEM_CODE=>order_detail.product_id,
                                                              :ITEM_NAME=> order_detail.product_name,
                                                              :ITEM_QTY=>order_detail.quantity,
                                                              :ITEM_PRICE=>order_detail.product_price,
                                                              :ITEM_CATG=>order_detail.product.category.name,
                                                              :TAXES=>(JSON.parse(order_detail.tax_details)  rescue {}).map{|entry|{
                                                                        :TAX_NAME=>entry["tax_type"],
                                                                        :TAX_AMT=>entry["tax_amount"],
                                                                        :TAX_PER=>entry["tax_percentage"]}},
                                                              :DISC_AMT=>order_detail.discount,
                                                              :NET_AMT=>order_detail.unit_price_with_tax}}},
                                                            :PAYMENTS=>data.payments.map{|payment| {
                                                                #:RECEIPT_NO=>"ALL READY MENTIONED WILL BE REMOVED",
                                                                :TIMESTAMP=>payment.created_at,
                                                                :RECORD_TYPE=>"CLARIFICATION REQUIRED",
                                                                :PAYMENT_NAME=>payment.paymentmode_type,
                                                                :CURR_CODE=>"NA",
                                                                :EXCHANGE_RATE=>"EXCHANGE_RATE",
                                                                :AMOUNT=>payment.paymentmode.amount
                                                              }}

                                                            }}}
        end
      rescue Exception => e
        respond_to do |format|
          format.json{render :json=>{:error=>e.message}}
        end
      end
  end

  private

  def check_transfer_possibility(store_id,product_id,_total_qty)
    _current_stock = StockUpdate.current_stock(store_id,product_id)
    if _current_stock.to_f < _total_qty.to_f
      return 1
    else
      return 0
    end
  end
end
