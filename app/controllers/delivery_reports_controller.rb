class DeliveryReportsController < ApplicationController

	include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_timerange, only: [:delivery_boys_report]

	def index
		@units = Unit.order("unit_name asc")
		_unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
   	@menu_cards = MenuCard.set_mode(1).set_unit(_unit_id).not_trashed
	end
	
	def slot_specific_delivery_reports
		@orders_date = Order.by_delivery_date_range(params[:from_date],params[:to_date]).pluck("Date(delivary_date)").uniq
		@data=[]
		@date_hash={}
		slot_hash=Hash.new
		
		@orders_date.each do  |orders_date|
			slot_hash=Hash.new
			@orders_slot = OrderDetail.by_delivery_date(orders_date).order("slot_id ASC").select("DISTINCT slot_id")
			@orders_slot.each do |order_slot|

				if order_slot.slot_id != nil
					product_details = []
					@orders = OrderDetail.by_delivery_date(orders_date).by_status('approved').by_slot(order_slot.slot_id).select("product_id,size_name,sum(quantity) AS quantity").group("product_id,size_name")
					@orders.each do |orders|
						puts orders.inspect
						product_details.push({"product_id"=>orders.product_id,"size_name"=>orders.size_name,"quantity"=>orders.quantity})
					end
					slot_hash["#{order_slot.slot.title} (start #{order_slot.slot.start_time.strftime("%I:%M %p")} end #{order_slot.slot.end_time.strftime("%I:%M %p")})"]	= product_details
				end
			end
			@date_hash["#{orders_date}"]=slot_hash.clone
		end
		respond_to do |format|
			format.html
			format.csv{send_data slot_specific_delivery_reports_csv_report(@date_hash) ,file_name: "slot_specific_delivery_reports from-#{params[:from_date]} to #{params[:to_date]}.csv"}
		end
	end	

	def delivery_boys_report
		if params[:unit_id].present?
			@unit_id = params[:unit_id]
			@delivery_boys = Unit.find(params[:unit_id]).delivery_boys
		else
			@unit_id = current_user.unit.id
    	@delivery_boys = current_user.unit.delivery_boys
    end
    @delivery_boys = @delivery_boys.search_by_name(params[:name_filter]) if params[:name_filter].present?
    smart_listing_create :delivery_boys_list, @delivery_boys, partial: "delivery_reports/delivery_boys_list_smartlist"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv{send_data delivery_boys_reports_csv_report(@delivery_boys,@from_datetime,@to_datetime) ,file_name: "delivery_boys_reports from-#{params[:from_date]} to #{params[:to_date]}.csv"}
    end
	end
	
	def fetch_product_name(id)
		product = Product.find(id)
		return product.name
	end
	def product_unit_name(id)
		product=Product.find(id)
		unit_name=ProductUnit.select(:name).where("product_basic_unit_id=?",product.basic_unit_id).first
		return unit_name.name
	end
	def slot_specific_delivery_reports_csv_report(data)
      csv_header=["Date","slot","product_name","product_size","quantity"]
      CSV.generate do |csv|
      	csv<<csv_header
      	data.each do |key,value|
      		csv<<[key,"","","",""]
      		value.each do |slot,product|
      			csv<<["",slot,"","",""]
      			product.each do |product|
      				csv<<["","",fetch_product_name(product["product_id"]),product["size_name"],"#{product["quantity"]} #{product_unit_name(product["product_id"])}"]
      			end
      		end	
      	end
      end
  end
  def delivery_boys_reports_csv_report(delivery_boys,from_datetime,to_datetime)
  	csv_header=["Delivery Boy","Order collection count","Delivery count","Order Date","Payment mode","Collection Amount (#{currency})"]
  	CSV.generate do |csv|
      csv<<csv_header
      delivery_boys.each do |object|
      	delivery_boy_orders = object.orders.by_recorded_at(from_datetime,to_datetime)
      	csv<<[object.name,delivery_boy_orders.Picked?.count,delivery_boy_orders.Delivered?.count,'','','']
      	delivery_boy_orders.each do |db_order|
      		csv<<['','','',db_order.recorded_at.strftime("%Y-%m-%d"),'','']
      		bills = db_order.bills
          bills.each do |bill|
            bill_payments = bill.payments
            bill_payments.each do |payment|
            	_paymentmode_type = payment.paymentmode_type == 'ThirdPartyPayment' ? payment.paymentmode.third_party_payment_option_name : payment.paymentmode_type
            	csv<<['','','','',_paymentmode_type,payment.paymentmode.amount]
            end
          end
      	end
      end
    end
  end
end