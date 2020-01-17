module Api
	module V2
		class ReportsController < ApplicationController
			before_filter :set_timerange
			def get_dashboard_data
				@sales_data 					= Bill.unit_bills(params[:unit_id]).valid_bill.select("date(created_at) as date, sum(grand_total) as total_price").group("date(created_at)").order("date(created_at)").check_bill_by_date(@from_datetime,@to_datetime)
				@orders_data 					= Order.by_unit_id(params[:unit_id]).not_canceled.select("date(created_at) as date, count(id) as order_count").group("date(created_at)").order("date(created_at)").order_by_date(@from_datetime,@to_datetime)
				@order_source 				= Order.by_unit_id(params[:unit_id]).select("count(id) as value, source as label").group("source").order_by_date(@from_datetime,@to_datetime)
				@cog_data 						= OrderDetail.select("date(created_at) as date, sum(material_cost+(customization_price * quantity)) as cog").group("date(created_at)").set_unit_in(params[:unit_id]).order("date(created_at)").order_detail_by_date(@from_datetime,@to_datetime)
				@products_by_price 		= OrderDetail.most_sold_items_by_price.set_unit_in(params[:unit_id]).by_date_range(@from_datetime,@to_datetime).valid_item.first(10)
				@products_by_qnantity = OrderDetail.most_sold_items_by_quantity.set_unit_in(params[:unit_id]).by_date_range(@from_datetime,@to_datetime).valid_item.first(10)
				@settlement_data 			= Bill.get_unit_settlement_data(params[:unit_id],@from_datetime,@to_datetime)
				@cash_sell 						= Cash.where(:id=>Bill.unit_bills(params[:unit_id]).check_bill_by_date(@from_datetime,@to_datetime).joins(:payments).where(payments: { paymentmode_type: 'Cash' }).pluck(:paymentmode_id)).select("date(created_at) as date, sum(amount) as total_price").group("date(created_at)").order("date(created_at)")
				@card_sell 						= Card.where(:id=>Bill.unit_bills(params[:unit_id]).check_bill_by_date(@from_datetime,@to_datetime).joins(:payments).where(payments: { paymentmode_type: 'Card' }).pluck(:paymentmode_id)).select("date(created_at) as date, sum(amount) as total_price").group("date(created_at)").order("date(created_at)")
			end

			api :GET, '/api/v2/reports/get_bill_report', "Bill report for a given date range."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :unit_id, String, :required => true, :desc => "Filter bills of an unit"
      param :from_date, String, :required => true, :desc => "From date for date range ",:meta => "`date format` in 2017-10-20"
      param :to_date, String, :required => true, :desc => "To date for date range",:meta => "`date format` in 2017-10-20"
			param :bill_device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			def get_bill_report
				_per 							= params[:count] || 20
				if params[:bill_device_id].present?
					@bills 						= Bill.unit_bills(params[:unit_id]).valid_bill.by_date_range(@from_datetime,@to_datetime).set_device(params[:bill_device_id])
					@bills_count 			= @bills.count
					@bills 						= @bills.page(params[:page]).per(_per) if params[:page].present?
					@total_sale 			= Bill.select("sum(bill_amount) as total_bill_amount, sum(grand_total) as total_grand_total, sum(tax_amount) as total_tax, sum(discount) as total_discount, sum(pax) as total_pax").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.set_device(params[:bill_device_id])
					@table_sale 			= Bill.select("sum(pax) as total_pax, sum(grand_total) as table_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.set_deliverable_type("resource").set_device(params[:bill_device_id])
					@void_sale 				= Bill.select("sum(bill_amount) as void_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).void_bill.set_device(params[:bill_device_id])
					@nc_sale 					= Bill.select("sum(bill_amount) as nc_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).nc_bill.set_device(params[:bill_device_id])
					@cod_sale 				= Bill.select("sum(grand_total) as cod_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.cod_sale.set_device(params[:bill_device_id])
					@section_sale 		= Bill.select("sum(grand_total) as section_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.set_deliverable_type("section").set_device(params[:bill_device_id])
					@take_away_sale 	= Bill.select("sum(grand_total) as take_away_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.take_away_bill.set_device(params[:bill_device_id])
					@settlement_data 	= Bill.get_device_settlement_data(params[:unit_id],@from_datetime,@to_datetime,params[:bill_device_id])
					@boh_amount 			= Bill.select("sum(boh_amount) as total_boh_amount").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).boh_bill.set_device(params[:bill_device_id])
					@return_amount 		= ReturnItem.select("sum(price) as total_return_amount").unit_return(params[:unit_id]).by_date_range(@from_datetime,@to_datetime).set_device(params[:bill_device_id])
					@cash_return 			= ReturnItem.select("sum(price) as total_cash_return_amount").unit_return(params[:unit_id]).by_date_range(@from_datetime,@to_datetime).set_device(params[:bill_device_id]).cash_return
					@wallet_return 		= ReturnItem.select("sum(price) as total_wallet_return_amount").unit_return(params[:unit_id]).by_date_range(@from_datetime,@to_datetime).set_device(params[:bill_device_id]).wallet_return
				else
					@bills 						= Bill.unit_bills(params[:unit_id]).valid_bill.by_date_range(@from_datetime,@to_datetime)
					@bills_count 			= @bills.count
					@bills 						= @bills.page(params[:page]).per(_per) if params[:page].present?
					@total_sale 			= Bill.select("sum(bill_amount) as total_bill_amount, sum(grand_total) as total_grand_total, sum(tax_amount) as total_tax, sum(discount) as total_discount, sum(pax) as total_pax").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill
					@table_sale 			= Bill.select("sum(pax) as total_pax, sum(grand_total) as table_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.set_deliverable_type("resource")
					@void_sale 				= Bill.select("sum(bill_amount) as void_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).void_bill
					@nc_sale 					= Bill.select("sum(bill_amount) as nc_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).nc_bill
					@cod_sale 				= Bill.select("sum(grand_total) as cod_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.cod_sale
					@section_sale 		= Bill.select("sum(grand_total) as section_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.set_deliverable_type("section")
					@take_away_sale 	= Bill.select("sum(grand_total) as take_away_sale").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.take_away_bill
					@settlement_data 	= Bill.get_unit_settlement_data(params[:unit_id],@from_datetime,@to_datetime)
					@return_amount 		= ReturnItem.select("sum(price) as total_return_amount").unit_return(params[:unit_id]).by_date_range(@from_datetime,@to_datetime)
					@cash_return 			= ReturnItem.select("sum(price) as total_cash_return_amount").unit_return(params[:unit_id]).by_date_range(@from_datetime,@to_datetime).cash_return
					@wallet_return 		= ReturnItem.select("sum(price) as total_wallet_return_amount").unit_return(params[:unit_id]).by_date_range(@from_datetime,@to_datetime).wallet_return
					@third_party_sale_details = Bill.get_unit_third_party_settlement_data(params[:unit_id],@from_datetime,@to_datetime)
					@coupon_sale_details  = Bill.get_unit_coupon_settlement_data(params[:unit_id],@from_datetime,@to_datetime)
					@boh_amount 			= Bill.select("sum(boh_amount) as total_boh_amount").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).boh_bill
				end	
			end

			api :GET, '/api/v2/reports/get_item_report', "Item report for a given date range."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :unit_id, String, :required => true, :desc => "Filter bills of an unit"
      param :from_date, String, :required => true, :desc => "From date for date range ",:meta => "`date format` in 2017-10-20"
      param :to_date, String, :required => true, :desc => "To date for date range",:meta => "`date format` in 2017-10-20"
			param :bill_device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			def get_item_report
				_per 							= params[:count] || 20
				if params[:bill_device_id].present?
					order_id_for_bill = Bill.unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.set_device(params[:bill_device_id]).map{|bill| bill.orders.map{|order| order.id}}.flatten
					_menu_products 		= OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).uniq.pluck(:menu_product_id)
					@count 						= _menu_products.count
					_menu_products		= Kaminari.paginate_array(_menu_products).page(params[:page]).per(_per) if params[:page].present?
					@category_sales 	= OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>_menu_products).group("menu_product_id,product_name,product_id,product_unique_identity").select("product_id,product_name,product_unique_identity as sku,menu_product_id,SUM(unit_price_without_tax * quantity) as total_sale, SUM(quantity) as quantity")
					@total_sale 			= Bill.select("sum(bill_amount) as total_bill_amount, sum(grand_total) as total_grand_total, sum(tax_amount) as total_tax, sum(discount) as total_discount, sum(pax) as total_pax").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.set_device(params[:bill_device_id])
					@settlement_data 	= Bill.get_device_settlement_data(params[:unit_id],@from_datetime,@to_datetime,params[:bill_device_id])
				else
					order_id_for_bill = Bill.unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill.map{|bill| bill.orders.map{|order| order.id}}.flatten
					_menu_products 		= OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).uniq.pluck(:menu_product_id)
					@count 						= _menu_products.count
					_menu_products		= Kaminari.paginate_array(_menu_products).page(params[:page]).per(_per) if params[:page].present?
					@category_sales 	= OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>_menu_products).group("menu_product_id,product_name,product_id,product_unique_identity").select("product_id,product_name,product_unique_identity as sku,menu_product_id,SUM(unit_price_without_tax * quantity) as total_sale, SUM(quantity) as quantity")
					@total_sale 			= Bill.select("sum(bill_amount) as total_bill_amount, sum(grand_total) as total_grand_total, sum(tax_amount) as total_tax, sum(discount) as total_discount, sum(pax) as total_pax").unit_bills(params[:unit_id]).by_recorded_at(@from_datetime,@to_datetime).valid_bill
					@settlement_data 	= Bill.get_unit_settlement_data(params[:unit_id],@from_datetime,@to_datetime)
				end	
			end

			def get_product_sales
        @from_datetime = params[:from_date]
        @to_datetime = params[:to_date]
        unit_id = params[:unit_id]
        @prduct_quantity = OrderDetail.select("menu_product_id,product_id, product_name, sum(quantity) as total_qty, date(created_at) as date").group('menu_product_id, date(created_at), product_name,product_id').by_date_range(@from_datetime,@to_datetime).valid_item.set_unit(unit_id).order("menu_product_id asc")
      end

		end
	end
end