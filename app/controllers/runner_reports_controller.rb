class RunnerReportsController < ApplicationController
	layout "material"
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include SaleReportsHelper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:by_date_range_delivery, :return_pickup_details]

  def index
    _units = Bill.select("DISTINCT(unit_id)")
    @units = Unit.get_unit_name(_units).order("unit_name asc")
    respond_to do |format|
      format.html
      format.json { render json: @menu_cards }
    end
  end

  def by_date_range_delivery
    _delivery_boy_ids = Order.select("DISTINCT(delivery_boy_id)")
    @delivery_boys = DeliveryBoy.where(:id => _delivery_boy_ids)
  	@unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
  	@orders = Order.by_unit_id(@unit_id).where("delivery_boy_id IS NOT NULL").order('delivery_boy_id asc')
  	@orders = @orders.by_delivery_date_range(@from_datetime,@to_datetime) if params[:from_date].present? and params[:to_date].present?
    @orders = @orders.order_by_delivery_boy_id(params[:delivery_boy_id]) if params[:delivery_boy_id].present?
    @orders = @orders.by_status(params[:order_status_id]) if params[:order_status_id].present?
    smart_listing_create :by_date_range_delivery, @orders, partial: "runner_reports/delivery_sales_smartlisting", page_sizes: [10]
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data by_date_range_delivery_to_csv(@orders), filename: "date-range-delivery-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def return_pickup_details
    _delivery_boy_ids = ReturnItem.select("DISTINCT(delivery_boy_id)")
    @delivery_boys = DeliveryBoy.where(:id => _delivery_boy_ids)
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @return_items = ReturnItem.unit_return(@unit_id).where("delivery_boy_id IS NOT NULL").order('delivery_boy_id asc')
    @return_items = @return_items.by_date_range(@from_datetime,@to_datetime) if params[:from_date].present? and params[:to_date].present?
    @return_items = @return_items.by_delivery_boy(params[:delivery_boy_id]) if params[:delivery_boy_id].present?
    smart_listing_create :return_pickup_details, @return_items, partial: "runner_reports/return_pickup_details_smartlisting", page_sizes: [10]
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data return_pickup_details_to_csv(@return_items), filename: "return-pickup-details-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  private

  def by_date_range_delivery_to_csv(data)
    CSV.generate do |csv|
      csv << [ "Delivery Boy","Order Id",'Customer Name','Address','Delivery Date', 'Order status']
      data.each do |order|
        if order.customer.present?
          if order.customer.customer_profile.present?
            _customer_name = "#{order.customer.customer_profile.firstname} #{order.customer.customer_profile.lastname}"
          else
            _customer_name  = '-'
          end
        else
          _customer_name  = '-'
        end
        csv << [order.delivery_boy.name, order.id, _customer_name, order.deliverable.delivery_address,order.delivary_date.strftime("%Y-%m-%d"), order.order_status.name]
        order.order_details.each do |o_d|
          _item_status = o_d.trash == 1 ? 'Cancelled' : 'Approved'
          csv << ['',o_d.product_name,"#{o_d.quantity} #{o_d.product.basic_unit}",_item_status]
        end
      end
    end
  end

  def return_pickup_details_to_csv(data)
    CSV.generate do |csv|
      csv << [ "Delivery Boy","Order Id",'Customer Name','Pick From','Item Name', 'Quantity', 'Sku', 'Drop At']
      data.each do |return_item|
        if return_item.order.customer.present?
          if return_item.order.customer.customer_profile.present?
            _customer_name = "#{return_item.order.customer.customer_profile.firstname} #{return_item.order.customer.customer_profile.lastname}"
          else
            _customer_name  = '-'
          end
        else
          _customer_name  = '-'
        end
        csv << [return_item.delivery_boy.name, return_item.order.id, _customer_name, return_item.order.deliverable.delivery_address, return_item.product.name, "#{return_item.quantity} #{return_item.product.basic_unit}", return_item.sku, return_item.order.unit.address]
      end
    end
  end

  def set_module_details
    @module_id = "reports"
    @module_title = "Runner Report"
  end 
end
