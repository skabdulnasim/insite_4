module PurchaseOrderManagement
########################################
## save requition in store stock table  (Deprecated function)
########################################
  def self.save_purchase_order_stocks(id)
    @purchase_order_details = PurchaseOrder.where(:id => id)
    @purchase_order_meta = PurchaseOrderMetum.where(:purchase_order_id => id)
    @purchase_order_serial=(Time.now.to_i).to_s+id+(rand(100)).to_s
    @purchase_order_meta.each do |purchase_order_meta|
      puts purchase_order_meta.id
      @purchase_order_stock = PurchaseOrderStock.new
      @purchase_order_stock[:product_id] = purchase_order_meta.product_id
      #@purchase_order_stock[:from_store] = @purchase_order_details[0].to_store
      @purchase_order_stock[:store_id] = @purchase_order_details[0].store_id
      @purchase_order_stock[:vendor_id] = @purchase_order_details[0].vendor_id
      #@purchase_order_stock[:activity_id] = 2
      @purchase_order_stock[:purchase_order_id] = id
      @purchase_order_stock[:status] = "1"
      current_time = Time.now.strftime("%d-%m-%Y %H:%M")
      #Prepare status JSON
      @json_status = {}
      @arr = {}
      @arr[:status_id] = "1"
      @arr[:status_short_desc] = "Purchase order placed"
      @arr[:status_long_desc] = "Purchase order has been successfully placed"
      @arr[:time] = current_time
      @purchase_order_stock[:po_serial_no] = @purchase_order_serial
      @app_configuration = AppConfiguration.where(:config_key => "purchase_order_auto_adjust").first
      
      # checking fro "req_auto_adjust" is on or off
      if @app_configuration[:config_value] == "1"
        #getting the cureent product current stock
        current_product_stock = StoreManagement::get_product_stock_details(purchase_order_meta.product_id,@purchase_order_details[0].store_id)
        #checking if the current stong is less then current requirement
        if current_product_stock.to_f < purchase_order_meta.product_amount.to_f
          @arr[:requested_amount] = purchase_order_meta.product_amount - current_product_stock
          @json_status[1]=@arr
          @status_log_json = JSON.generate(@json_status)
          @purchase_order_stock[:status_log] = @status_log_json
          @purchase_order_stock[:po_stock] = @arr[:requested_amount]
          @purchase_order_stock.save
        end
      else
        @arr[:requested_amount] = purchase_order_meta.product_amount
        @json_status[1]=@arr
        @status_log_json = JSON.generate(@json_status)
        @purchase_order_stock[:status_log] = @status_log_json
        @purchase_order_stock[:po_stock] = @arr[:requested_amount]
        @purchase_order_stock.save
      end
      
    end
    return @purchase_order_details
  end
  def self.get_po_details_by_serial_no(id)
    _po_details = PurchaseOrderStock.where(:po_serial_no => id).first
    return _po_details
  end
############################################ 
end