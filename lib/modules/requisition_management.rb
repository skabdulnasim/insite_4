module RequisitionManagement
########################################
## save requition in store stock table 
########################################
  def self.save_requisition_store_stocks(id)
    puts "This is a dummy work created the sumit dey, here the updated code for recurring save_requisition_store_stocks has to be uploded. file location lib/module/requisition_management.rb"
    # @requisition_details = StoreRequisition.find(:all, :conditions => [ 'id =?', id])
    # @requisition_meta = StoreRequisitionMetum.find(:all, :conditions => [ 'requisition_id =?', id])
    # @requisition_serial=(Time.now.to_i).to_s+id
    # @requisition_meta.each do |requisition_meta|
    #   @store_stock = StoreStock.new
    #   @store_stock[:product_id] = requisition_meta.product_id
    #   @store_stock[:from_store] = @requisition_details[0].to_store
    #   @store_stock[:store_id] = @requisition_details[0].to_store
    #   @store_stock[:to_store] = @requisition_details[0].store_id
    #   @store_stock[:activity_id] = 2
    #   @store_stock[:store_requisition_id] = id
    #   @store_stock[:status] = "1.1"
    #   current_time = Time.now.strftime("%d-%m-%Y %H:%M")
    #   #Prepare status JSON
    #   @json_status = {}
    #   @arr = {}
    #   @arr[:status_id] = "1.1"
    #   @arr[:status_short_desc] = "Order placed"
    #   @arr[:status_long_desc] = "Product requisition has been successfully placed"
    #   @arr[:time] = current_time
    #   @store_stock[:requisition_serial_no] = @requisition_serial
    #   @app_configuration = AppConfiguration.find(:first, :conditions => ['config_key =?', "req_auto_adjust"])
    #   # checking fro "req_auto_adjust" is on or off
    #   if @app_configuration[:config_value] == "1"
    #     #getting the cureent product current stock
    #     current_product_stock = StoreManagement::get_product_stock_details(requisition_meta.product_id,@requisition_details[0].store_id)
    #     #checking if the current stong is less then current requirement
    #     if current_product_stock.to_f < requisition_meta.product_ammount.to_f
    #       @arr[:requested_amount] = requisition_meta.product_ammount - current_product_stock
    #       @json_status[1.1]=@arr
    #       @status_log_json = JSON.generate(@json_status)
    #       @store_stock[:status_json] = @status_log_json
    #       @store_stock[:requisition_stock] = @arr[:requested_amount]
    #       @store_stock.save
    #     end
    #   else
    #     @arr[:requested_amount] = requisition_meta.product_ammount
    #     @json_status[1.1]=@arr
    #     @status_log_json = JSON.generate(@json_status)
    #     @store_stock[:status_json] = @status_log_json
    #     @store_stock[:requisition_stock] = @arr[:requested_amount]
    #     @store_stock.save
    #   end
      
    # end
    # return @requisition_details
  end
############################################ 
end