class InventoryDashboardsController < ApplicationController
	layout "material"

	include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

	before_filter :set_module_details
	before_filter :set_timerange

  def index
  	@total_purchase_arr = []
    @opening_stock_arr = []
    @audit_id = []
    @pending_audit_id = []
    @delta_value = []
    @pending_delta_value = []
    @store_arr = []
    @purchase = []

    # ********** Today's beginning and end time **************
		@end_of_day_time = Time.zone.now.end_of_day.strftime("%Y-%m-%d %H:%M:%S")
		@beginning_of_day_time = Time.zone.now.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
		@today_date = Date.today.strftime("%Y-%m-%d")

    if current_user.role.name == "owner"
    	#*************** Stock in hand *****************
			@unit_id = []
			@current_user.unit.children.map { |e| @unit_id.push e.id } if @current_user.unit.children.present?
      @unit_id << @current_user.unit.id
      @child_units = Unit.set_id_in(@unit_id)
      @store_details = Store.set_unit_in(@unit_id)
	  	@store_details.each do |store|
	  		@store_arr.push(store.id)  
	  	end
      if params['units_idss'].present?
	      @unit_arr = params['units_idss'] 
	      @units = Unit.set_id_in(@unit_arr)
	      @store_details = Store.set_unit_in(@unit_arr)
	    end
			@distinct_stock_update_id = StockUpdate.uniq.pluck(:product_id)
			@stock_in_hand = StockUpdate.get_product_in(@distinct_stock_update_id).select("count(*) as count, sum(stock) as available_stock, product_id").group("product_id")

			# ****************  Product search  ******************
			if params[:product_name].present? and Product.find_by_name(params[:product_name]).present?
				@product = Product.find_by_name(params[:product_name])
				if StockUpdate.by_product(@product.id).set_store_in(@store_arr).where('Date(created_at) =(?)',params[:from_date]).present?
					@opening_stock = StockUpdate.by_product(@product.id).set_store_in(@store_arr).where('Date(created_at) =(?)',params[:from_date]).select("stock").first 
					@closing_stock = StockUpdate.by_product(@product.id).set_store_in(@store_arr).where('Date(created_at) =(?)',params[:to_date]).select("stock").last
					@purchase.push Stock.get_product(@product.id).set_store_in(@store_arr).set_transaction_type("StockPurchase").where('Date(created_at) =(?)',params[:from_date]).select("Date(created_at) as created_time, price as total_purchase").last 
				end
			elsif params[:from_date].present? && params[:to_date].present?
				@purchase = Stock.by_date_range(@from_datetime,@to_datetime).set_store_in(@store_arr).set_transaction_type("StockPurchase").select("Date(created_at) as created_time, sum(price) as total_purchase").group("Date(created_at)").order("Date(created_at) ASC")
			else
				@purchase = Stock.last_week.set_transaction_type("StockPurchase").set_store_in(@store_arr).select("Date(created_at) as created_time, sum(price) as total_purchase").group("Date(created_at)").order("Date(created_at) ASC")
			end
			# **************** Opening stock per day *****************
			@product_id_arr = StockUpdate.set_store_in(@store_arr).where('Date(created_at) =(?)',Date.yesterday).uniq.pluck(:product_id)
			@openingstock_per_day_arr = []
			@stock_price_arr = []
			@product_id_arr.each do |pro_id|
				@openingstock_per_day_arr.push(StockUpdate.set_store_in(@store_arr).where('Date(created_at) =(?) and product_id=?',Date.yesterday,pro_id).select("stock").last)
				@stock_price_arr.push(Stock.set_store_in(@store_arr).where('product_id=?',pro_id).select("price").last)
			end
			if @openingstock_per_day_arr.present?
				@product_price = []
				@stock_price_arr.each do |s|
					@product_price.push(s.price)
				end
				@product_stock = []
				@openingstock_per_day_arr.each do |k|
					@product_stock.push(k.stock)
				end
				@sum_each = @product_price.zip(@product_stock).map{|x, y| x * y}
				@openingstock = @sum_each.sum
 			end

			# **************** closing stock per day *********************
			@product_id = StockUpdate.set_store_in(@store_arr).where('Date(created_at) =(?)',@today_date).uniq.pluck(:product_id)
			@closingstock_per_day_arr = []
			@stock_price = []
			@product_id.each do |pro_id|
				@closingstock_per_day_arr.push(StockUpdate.set_store_in(@store_arr).where('Date(created_at) =(?) and product_id=?',@today_date,pro_id).select("stock").last)
				@stock_price.push(Stock.set_store_in(@store_arr).where('product_id=?',pro_id).select("price").last)
			end
			if @closingstock_per_day_arr.present?
				@product_price_arr = []
				@stock_price.each do |s|
					@product_price_arr.push(s.price)
				end
				@product_stock_arr = []
				@closingstock_per_day_arr.each do |k|
					@product_stock_arr.push(k.stock)
				end
				if !@product_price_arr && @product_stock_arr == ""
					@sum_each = @product_price_arr.zip(@product_stock_arr).map{|x, y| x * y} 
					@closingstock = @sum_each.sum
				end
			end
			# ************* Purchase per day *****************
			@stocks = Stock.set_store_in(@store_arr).type_credit.where('Date(created_at) =(?)',@today_date).set_transaction_type("StockPurchase").select("sum(available_stock * price) as total_purchase, product_id").group("product_id")
			@stocks.each do |purchase|
				@purchase_per_day = purchase.total_purchase.to_i
			end

			#**************** Purchase Status *************
			@purchase_received_per_day = StockPurchase.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).received
			@total_receive_amount = []
			@total_pertially_receive_amount = []
			@total_pending_amount = []
			@purchase_received_per_day.each do |tr_amount|
				@total_receive_amount.push(tr_amount.total_amount)
			end
			@purchase_pending_per_day = StockPurchase.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).pending_pos
			@purchase_pending_per_day.each do |tp_amount|
				@total_pending_amount.push(tp_amount.total_amount)
			end
			@purchase_order_create = PurchaseOrder.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s)
			@purchase_order_create_amount_arr = []
			@purchase_order_create.each do |poc|
				poc.purchase_order_metum.each do |poc_amount|
					@purchase_order_create_amount_arr.push poc_amount
				end
			end
			@stock_purchase_receive_count = Stock.set_store_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).set_transaction_type("StockPurchase")
			@stock_purchase_pending_count_arr = []
			@purchase_pending_per_day.each do |po_status|
				po_status.purchase_order.purchase_order_metum.each do |pom|
					@stock_purchase_pending_count_arr.push pom
				end
			end
			@purchase_received_pertially = StockPurchase.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).partially_received
			@sp_id_arr = []
			@purchase_received_pertially.each do |tpr_amount|
				@total_pertially_receive_amount.push(tpr_amount.total_amount)
				@sp_id_arr.push tpr_amount.id
			end
			@pertially_sp_count = Stock.set_transaction_in(@sp_id_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).set_transaction_type("StockPurchase")

			# ***************** Auidt(Approved and Pending) *****************
			@approved_audit = StockAudit.approved_audit.set_store_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s)
			@pending_audit = StockAudit.pending_audit.set_store_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s)
			# audit receive
			@approved_audit.each do |audit|
				@audit_id.push(audit.id) 
			end
			@delta_stock_value = StockAuditMeta.get_audit_in(@audit_id)
			@delta_stock_value.each do |value|
 				@delta_value.push(value.delta_stock * -1) if (value.delta_stock) < 0
 				@delta_value.push(value.delta_stock) if (value.delta_stock) > 0
			end
			@delta_value = @delta_value.sum.to_f
			@delta_negative_val = []
			@delta_positive_val = []
			@delta_stock_value.each do |delta_positive_negative_val|
				@delta_negative_val.push(delta_positive_negative_val.delta_stock * -1) if (delta_positive_negative_val.delta_stock) < 0
 				@delta_positive_val.push(delta_positive_negative_val.delta_stock) if (delta_positive_negative_val.delta_stock) > 0
			end
			# audit pending
			@pending_audit.each do |audit|
				@pending_audit_id.push(audit.id) 
			end
			@pending_delta_stock_value = StockAuditMeta.get_audit_in(@pending_audit_id)
			@pending_delta_stock_value.each do |value|
 				@pending_delta_value.push(value.delta_stock * -1) if (value.delta_stock) < 0
 				@pending_delta_value.push(value.delta_stock) if (value.delta_stock) > 0
			end
			@pending_delta_value = @pending_delta_value.sum.to_f
			@pending_delta_negative_val = []
			@pending_delta_positive_val = []
			@pending_delta_stock_value.each do |delta_positive_negative_val|
				@pending_delta_negative_val.push(delta_positive_negative_val.delta_stock * -1) if (delta_positive_negative_val.delta_stock) < 0
 				@pending_delta_positive_val.push(delta_positive_negative_val.delta_stock) if (delta_positive_negative_val.delta_stock) > 0
			end
			@no_of_product_audit_apprived = []
			@no_of_product_audit_pending = []
			@approved_audit.each do |paa|
				paa.stock_audit_metas.each do |paa_no|
					@no_of_product_audit_apprived.push paa_no
				end
			end
			@pending_audit.each do |pap|
				pap.stock_audit_metas.each do |pap_no|
					@no_of_product_audit_pending.push pap_no
				end
			end
			smart_listing_create :stock_in_hand, @stock_in_hand, partial: "inventory_dashboards/stock_in_hand_smartlist"
	  	respond_to do |format|
	  		format.html
	      format.json {render json: {all_data: {purchase: @purchase, opening_stock: @opening_stock, closing_stock: @closing_stock }}} 
	    	format.js
	    end

	  elsif current_user.role.name == "bill_manager" || current_user.role.name == "dc_manager" || current_user.role.name == "outlet_manager"
	  	#******************** stock in hand ********************
	  	@unit_id = []
			@current_user.unit.children.map { |e| @unit_id.push e.id } if @current_user.unit.children.present?
      @unit_id << @current_user.unit.id
      @child_units = Unit.set_id_in(@unit_id)
      @store_details = Store.set_unit_in(@unit_id)
      if params['units_idss'].present?
	      @unit_arr = params['units_idss']
	      @store_details = Store.set_unit_in(@unit_arr)
	    end
      @store_details.each do |store|
	  		@store_arr.push(store.id)  
	  	end
			@distinct_stock_update_id = StockUpdate.uniq.pluck(:product_id)
			@stock_in_hand = StockUpdate.get_product_in(@distinct_stock_update_id).select("count(*) as count, sum(stock) as available_stock, product_id").group("product_id") #stock in hand of all product

			# ************ Opening stock per day **************
			@product_id_arr = StockUpdate.set_store_in(@store_arr).where('Date(created_at) =(?)',Date.yesterday).uniq.pluck(:product_id)
			@openingstock_per_day_arr = []
			@stock_price_arr = []
			@product_id_arr.each do |pro_id|
				@openingstock_per_day_arr.push(StockUpdate.set_store_in(@store_arr).where('Date(created_at) =(?) and product_id=?',Date.yesterday,pro_id).select("stock").last)
				@stock_price_arr.push(Stock.set_store_in(@store_arr).select("price").last)
			end
			@product_price = []
			@stock_price_arr.each do |s|
				@product_price.push(s.price)
			end
			@product_stock = []
			@openingstock_per_day_arr.each do |k|
				@product_stock.push(k.stock)
			end
			@sum_each = @product_price.zip(@product_stock).map{|x, y| x * y} if @product_price.present?

			# **************** closing stock per day *********************
			@product_id = StockUpdate.where('Date(created_at) =(?)',@today_date).set_store_in(@store_arr).uniq.pluck(:product_id)
			@closingstock_per_day_arr = []
			@stock_price = []
			@product_id.each do |pro_id|
				@closingstock_per_day_arr.push(StockUpdate.where('Date(created_at) =(?) and product_id=?',@today_date,pro_id).set_store_in(@store_arr).select("stock").last)
				@stock_price.push(Stock.set_store_in(@store_arr).where('product_id=?',pro_id).select("price").last)
			end
			if @closingstock_per_day_arr.present?
				@product_price_arr = []
				@stock_price.each do |s|
					@product_price_arr.push(s.price)
				end
				@product_stock_arr = []
				@closingstock_per_day_arr.each do |k|
					@product_stock_arr.push(k.stock)
				end
				@sum_each = @product_price_arr.zip(@product_stock_arr).map{|x, y| x * y}
				@closingstock = @sum_each.sum
			end
			# ************* Purchase per day *****************
			@stocks = Stock.set_store_in(@store_arr).type_credit.where('Date(created_at) =(?)',@today_date).set_transaction_type("StockPurchase").select("sum(available_stock * price) as total_purchase, product_id").group("product_id")
			@stocks.each do |purchase|
				@purchase_per_day = purchase.total_purchase.to_i
			end
			#**************** Purchase Status *************
			@purchase_received_per_day = StockPurchase.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).received
			@total_receive_amount = []
			@total_pertially_receive_amount = []
			@total_pending_amount = []
			@purchase_received_per_day.each do |tr_amount|
				@total_receive_amount.push(tr_amount.total_amount)
			end
			@purchase_pending_per_day = StockPurchase.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).pending_pos
			@purchase_pending_per_day.each do |tp_amount|
				@total_pending_amount.push(tp_amount.total_amount)
			end
			@purchase_order_create = PurchaseOrder.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s)
			@purchase_order_create_amount_arr = []
			@purchase_order_create.each do |poc|
				poc.purchase_order_metum.each do |poc_amount|
					@purchase_order_create_amount_arr.push poc_amount
				end
			end
			@stock_purchase_receive_count = Stock.set_store_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).set_transaction_type("StockPurchase")
			@stock_purchase_pending_count_arr = []
			@purchase_pending_per_day.each do |po_status|
				po_status.purchase_order.purchase_order_metum.each do |pom|
					@stock_purchase_pending_count_arr.push pom
				end
			end
			@purchase_received_pertially = StockPurchase.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).partially_received
			@sp_id_arr = []
			@purchase_received_pertially.each do |tpr_amount|
				@total_pertially_receive_amount.push(tpr_amount.total_amount)
				@sp_id_arr.push tpr_amount.id
			end
			@pertially_sp_count = Stock.set_transaction_in(@sp_id_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).set_transaction_type("StockPurchase")

			# ************ Auidt(Approved and Pending) *************
			@approved_audit = StockAudit.approved_audit.set_store_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s)
			@pending_audit = StockAudit.pending_audit.set_store_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s)
			# audit receive
			@approved_audit.each do |audit|
				@audit_id.push(audit.id) 
			end
			@delta_stock_value = StockAuditMeta.get_audit_in(@audit_id)
			@delta_stock_value.each do |value|
 				@delta_value.push(value.delta_stock * -1) if (value.delta_stock) < 0
 				@delta_value.push(value.delta_stock) if (value.delta_stock) > 0
			end
			@delta_value = @delta_value.sum.to_f
			@delta_negative_val = []
			@delta_positive_val = []
			@delta_stock_value.each do |delta_positive_negative_val|
				@delta_negative_val.push(delta_positive_negative_val.delta_stock * -1) if (delta_positive_negative_val.delta_stock) < 0
 				@delta_positive_val.push(delta_positive_negative_val.delta_stock) if (delta_positive_negative_val.delta_stock) > 0
			end
			# audit pending
			@pending_audit.each do |audit|
				@pending_audit_id.push(audit.id) 
			end
			@pending_delta_stock_value = StockAuditMeta.get_audit_in(@pending_audit_id)
			@pending_delta_stock_value.each do |value|
 				@pending_delta_value.push(value.delta_stock * -1) if (value.delta_stock) < 0
 				@pending_delta_value.push(value.delta_stock) if (value.delta_stock) > 0
			end
			@pending_delta_value = @pending_delta_value.sum.to_f
			@pending_delta_negative_val = []
			@pending_delta_positive_val = []
			@pending_delta_stock_value.each do |delta_positive_negative_val|
				@pending_delta_negative_val.push(delta_positive_negative_val.delta_stock * -1) if (delta_positive_negative_val.delta_stock) < 0
 				@pending_delta_positive_val.push(delta_positive_negative_val.delta_stock) if (delta_positive_negative_val.delta_stock) > 0
			end
			@no_of_product_audit_apprived = []
			@no_of_product_audit_pending = []
			@approved_audit.each do |paa|
				paa.stock_audit_metas.each do |paa_no|
					@no_of_product_audit_apprived.push paa_no
				end
			end
			@pending_audit.each do |pap|
				pap.stock_audit_metas.each do |pap_no|
					@no_of_product_audit_pending.push pap_no
				end
			end
			# ************** Product search ****************
			if params[:product_name].present? and Product.find_by_name(params[:product_name]).present?
				@product = Product.find_by_name(params[:product_name])
				if StockUpdate.by_product(@product.id).set_store_in(@store_arr).where('Date(created_at) =(?)',params[:from_date]).present?
					@opening_stock = StockUpdate.by_product(@product.id).set_store_in(@store_arr).where('Date(created_at) =(?)',params[:from_date]).select("stock").first 
					@closing_stock = StockUpdate.by_product(@product.id).set_store_in(@store_arr).where('Date(created_at) =(?)',params[:to_date]).select("stock").last
					@purchase.push Stock.get_product(@product.id).set_store_in(@store_arr).set_transaction_type("StockPurchase").where('Date(created_at) =(?)',params[:from_date]).select("Date(created_at) as created_time, price as total_purchase").last 
				end
			elsif params[:from_date].present? && params[:to_date].present?
				@purchase = Stock.by_date_range(@from_datetime,@to_datetime).set_store_in(@store_arr).set_transaction_type("StockPurchase").select("Date(created_at) as created_time, sum(price) as total_purchase").group("Date(created_at)").order("Date(created_at) ASC")
			else
				@purchase = Stock.last_week.set_transaction_type("StockPurchase").set_store_in(@store_arr).select("Date(created_at) as created_time, sum(price) as total_purchase").group("Date(created_at)").order("Date(created_at) ASC")
			end
			@value = 8
			smart_listing_create :stock_in_hand, @stock_in_hand, partial: "inventory_dashboards/stock_in_hand_smartlist"
	  	respond_to do |format|
	  		format.html
	      format.json {render json: {all_data: {value: @value, purchase: @purchase, opening_stock: @opening_stock, closing_stock: @closing_stock }}}
	    	format.js
	    end
	  else
	  	#******************** stock in hand  ********************
	  	@unit_id = []
      @unit_id << @current_user.unit.id
      @child_units = Unit.set_id_in(@unit_id)
      @store_details = Store.set_unit_in(@unit_id)
      @unit_arr = params['units_idss'] if params['units_idss'].present?
      @store_details = Store.set_unit_in(@unit_arr) if params['units_idss'].present?
      @store_details.each do |store|
	  		@store_arr.push(store.id)  
	  	end
	  	@distinct_stock_update_id = StockUpdate.uniq.pluck(:product_id)
			@stock_in_hand = StockUpdate.get_product_in(@distinct_stock_update_id).select("count(*) as count, sum(stock) as available_stock, product_id").group("product_id")
	  	# ************** Opening stock per day *****************
	  	@product_id_arr = StockUpdate.where('Date(created_at) =(?)',Date.yesterday).set_store_in(@store_arr).uniq.pluck(:product_id)
			@openingstock_per_day_arr = []
			@stock_price_arr = []
			@product_id_arr.each do |pro_id|
				@openingstock_per_day_arr.push(StockUpdate.set_store_in(@store_arr).where('Date(created_at) =(?) and product_id=?',Date.yesterday,pro_id).select("stock").last)
				@stock_price_arr.push(Stock.set_store_in(@store_arr).where('product_id=?',pro_id).select("price").last)
			end
			if @openingstock_per_day_arr.present?
				@product_price = []
				@stock_price_arr.each do |s|
					@product_price.push(s.price)
				end
				@product_stock = []
				@openingstock_per_day_arr.each do |k|
					@product_stock.push(k.stock)
				end
				@sum_each = @product_price.zip(@product_stock).map{|x, y| x * y}
				@openingstock = @sum_each.sum
 			end
 			# ************** closing stock per day *****************
 			@product_id = StockUpdate.where('Date(created_at) =(?)',@today_date).set_store_in(@store_arr).uniq.pluck(:product_id)
			@closingstock_per_day_arr = []
			@stock_price = []
			@product_id.each do |pro_id|
				@closingstock_per_day_arr.push(StockUpdate.set_store_in(@store_arr).where('Date(created_at) =(?) and product_id=?',@today_date,pro_id).select("stock").last)
				@stock_price.push(Stock.set_store_in(@store_arr).where('product_id=?',pro_id).select("price").last)
			end
			if @closingstock_per_day_arr.present?
				@product_price_arr = []
				@stock_price.each do |s|
					@product_price_arr.push(s.price)
				end
				@product_stock_arr = []
				@closingstock_per_day_arr.each do |k|
					@product_stock_arr.push(k.stock)
				end
				@sum_each = @product_price_arr.zip(@product_stock_arr).map{|x, y| x * y}
				@closingstock = @sum_each.sum
			end
			# ************** purchase per day *****************
			@stocks = Stock.set_store_in(@store_arr).type_credit.where('Date(created_at) =(?)',@today_date).set_transaction_type("StockPurchase").select("sum(available_stock * price) as total_purchase, product_id").group("product_id")
			@stocks.each do |purchase|
				@purchase_per_day = purchase.total_purchase.to_i
			end
			#**************** Purchase Status *************
			@purchase_received_per_day = StockPurchase.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).received
			@total_receive_amount = []
			@total_pertially_receive_amount = []
			@total_pending_amount = []
			@purchase_received_per_day.each do |tr_amount|
				@total_receive_amount.push(tr_amount.total_amount)
			end
			@purchase_pending_per_day = StockPurchase.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).pending_pos
			@purchase_pending_per_day.each do |tp_amount|
				@total_pending_amount.push(tp_amount.total_amount)
			end
			@purchase_order_create = PurchaseOrder.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s)
			@purchase_order_create_amount_arr = []
			@purchase_order_create.each do |poc|
				poc.purchase_order_metum.each do |poc_amount|
					@purchase_order_create_amount_arr.push poc_amount
				end
			end
			@stock_purchase_receive_count = Stock.set_store_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).set_transaction_type("StockPurchase")
			@stock_purchase_pending_count_arr = []
			@purchase_pending_per_day.each do |po_status|
				po_status.purchase_order.purchase_order_metum.each do |pom|
					@stock_purchase_pending_count_arr.push pom
				end
			end
			@purchase_received_pertially = StockPurchase.stores_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).partially_received
			@sp_id_arr = []
			@purchase_received_pertially.each do |tpr_amount|
				@total_pertially_receive_amount.push(tpr_amount.total_amount)
				@sp_id_arr.push tpr_amount.id
			end
			@pertially_sp_count = Stock.set_transaction_in(@sp_id_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s).set_transaction_type("StockPurchase")
			# **************** Auidt(Approved and Pending) ****************
			@approved_audit = StockAudit.approved_audit.set_store_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s)
			@pending_audit = StockAudit.pending_audit.set_store_in(@store_arr).where('Date(created_at) =(?)',DateTime.now.to_date.to_s)
			# audit receive
			@approved_audit.each do |audit|
				@audit_id.push(audit.id) 
			end
			@delta_stock_value = StockAuditMeta.get_audit_in(@audit_id)
			@delta_stock_value.each do |value|
 				@delta_value.push(value.delta_stock * -1) if (value.delta_stock) < 0
 				@delta_value.push(value.delta_stock) if (value.delta_stock) > 0
			end
			@delta_value = @delta_value.sum.to_f
			@delta_negative_val = []
			@delta_positive_val = []
			@delta_stock_value.each do |delta_positive_negative_val|
				@delta_negative_val.push(delta_positive_negative_val.delta_stock * -1) if (delta_positive_negative_val.delta_stock) < 0
 				@delta_positive_val.push(delta_positive_negative_val.delta_stock) if (delta_positive_negative_val.delta_stock) > 0
			end
			# audit pending
			@pending_audit.each do |audit|
				@pending_audit_id.push(audit.id) 
			end
			@pending_delta_stock_value = StockAuditMeta.get_audit_in(@pending_audit_id)
			@pending_delta_stock_value.each do |value|
 				@pending_delta_value.push(value.delta_stock * -1) if (value.delta_stock) < 0
 				@pending_delta_value.push(value.delta_stock) if (value.delta_stock) > 0
			end
			@pending_delta_value = @pending_delta_value.sum.to_f
			@pending_delta_negative_val = []
			@pending_delta_positive_val = []
			@pending_delta_stock_value.each do |delta_positive_negative_val|
				@pending_delta_negative_val.push(delta_positive_negative_val.delta_stock * -1) if (delta_positive_negative_val.delta_stock) < 0
 				@pending_delta_positive_val.push(delta_positive_negative_val.delta_stock) if (delta_positive_negative_val.delta_stock) > 0
			end
			@no_of_product_audit_apprived = []
			@no_of_product_audit_pending = []
			@approved_audit.each do |paa|
				paa.stock_audit_metas.each do |paa_no|
					@no_of_product_audit_apprived.push paa_no
				end
			end
			@pending_audit.each do |pap|
				pap.stock_audit_metas.each do |pap_no|
					@no_of_product_audit_pending.push pap_no
				end
			end
			# ************* Product search ********** 
			if params[:product_name].present? and Product.find_by_name(params[:product_name]).present?
				@product = Product.find_by_name(params[:product_name])
				if StockUpdate.by_product(@product.id).set_store_in(@store_arr).where('Date(created_at) =(?)',params[:from_date]).present?
					@opening_stock = StockUpdate.by_product(@product.id).set_store_in(@store_arr).where('Date(created_at) =(?)',params[:from_date]).select("stock").first 
					@closing_stock = StockUpdate.by_product(@product.id).set_store_in(@store_arr).where('Date(created_at) =(?)',params[:to_date]).select("stock").last
					@purchase.push Stock.get_product(@product.id).set_store_in(@store_arr).set_transaction_type("StockPurchase").where('Date(created_at) =(?)',params[:from_date]).select("Date(created_at) as created_time, price as total_purchase").last 
				end
			elsif params[:from_date].present? && params[:to_date].present?
				@purchase = Stock.by_date_range(@from_datetime,@to_datetime).set_store_in(@store_arr).set_transaction_type("StockPurchase").select("Date(created_at) as created_time, sum(price) as total_purchase").group("Date(created_at)").order("Date(created_at) ASC")
			else
				@purchase = Stock.last_week.set_transaction_type("StockPurchase").set_store_in(@store_arr).select("Date(created_at) as created_time, sum(price) as total_purchase").group("Date(created_at)").order("Date(created_at) ASC")
			end

			smart_listing_create :stock_in_hand, @stock_in_hand, partial: "inventory_dashboards/stock_in_hand_smartlist"
			respond_to do |format|
	  		format.html
	      format.json {render json: {all_data: {purchase: @purchase, opening_stock: @opening_stock, closing_stock: @closing_stock }}}
	      format.js
	    end
	  end 	
  end

  private
  def set_module_details
    @module_id = "dashboard"
    @module_title = "Inventory Dashboard"
  end
end
