class OrderReportsController < ApplicationController

	include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
	before_filter :set_timerange, only: [:home_delivery_order_reports]

	def index
    _units = Order.select("DISTINCT(unit_id)")
    @units = Unit.order(unit_name: :asc).get_unit_name(_units)
    respond_to do |format|
      format.html
    end
	end

	def home_delivery_order_reports
		@unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
		@unit = Unit.find(@unit_id)
		@orders = Order.by_unit_id(@unit_id).by_date_range(@from_datetime,@to_datetime).by_deliverable_type('Address').order('id asc')

		smart_listing_create :orders, @orders, partial: "order_reports/orders_smartlist"
	end

	def order_count_reports
		#for exrernal orders
		if params[:order_type] == "external_orders" 
			@orders = Order.by_recorded_at(params[:from_date],params[:to_date]).where("third_party_order_id IS NOT NULL") #external orders
			file_name = "external_order_report_#{params[:from_date]}-to-#{params[:to_date]}.csv"
		#for internal orders
		else 
			@orders = Order.where("third_party_order_id IS NULL").by_recorded_at(params[:from_date],params[:to_date]) #internal orders
			file_name = "internal_order_report_#{params[:from_date]}-to-#{params[:to_date]}.csv"
			puts "file name : #{file_name}"
		end
		@order_source = @orders.select("source,count(source)as total").group(:source)
		@orders = @orders.by_source(params[:source]) if params[:source].present?
		smart_listing_create :external_orders,@orders,partial: "order_reports/order_reports_smart_list"
		respond_to do |format|
			format.html
			format.js
			format.csv{send_data order_count_reports_csv(@orders,params[:order_type]),file_name: file_name}
		end
	end

	def internal_order_report
		
	end
	private
	def order_count_reports_csv(external_orders,order_type)
		CSV.generate do |csv|
			if order_type == "external_orders"
				csv<<["date","order_id","source","third party"]
			else
				csv<<["date","order_id","source"]
			end
			external_orders.each do |order|
				if order_type == "external_orders"
					csv<<[order.recorded_at,order.id,order.source,order.third_party_order_id]
				else
					csv<<[order.recorded_at,order.id,order.source]
				end
			end
		end
	end
	def internal_order_report_csv
	
	end

end