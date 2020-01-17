class SeReportsController < ApplicationController
	layout "material"
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include SaleReportsHelper
  include TspReportsHelper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:by_date_range, :day_by_day_order_reports,:day_by_day_shop_order_report, :shop_wise_order_summary_report]


  def index
    @units = Unit.by_unittype(3).order("unit_name asc")
    respond_to do |format|
      format.html
      format.json { render json: @menu_cards }
    end
  end

  def by_date_range
    if params[:user_id].present?
      @users = User.by_id(params[:user_id])
    elsif params[:se_filter].present?
      @roll_arr = Array.new
      sourcing_exec_role = Role.find_by_name("sourcing_exec")
      @roll_arr.push(sourcing_exec_role.id)
      @users = User.set_role(@roll_arr).by_unit(current_user.unit.id).by_name(params[:se_filter]).uniq
    else  
      @roll_arr = Array.new
      sourcing_exec_role = Role.find_by_name("sourcing_exec")
      @roll_arr.push(sourcing_exec_role.id)
      if current_user.role.name == "bill_manager"
        #bill_manager_role = Role.find_by_name("bill_manager")
        #@roll_arr.push(bill_manager_role.id)
        @users = User.set_role(@roll_arr).by_unit(current_user.unit.id)
      elsif current_user.role.name == "owner"
        @users = User.set_role(@roll_arr)
      elsif current_user.role.name == "dc_manager"
        @users = User.set_role(@roll_arr)  
      end
    end  

    smart_listing_create :user_list, @users, partial: "se_reports/se_list"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data by_date_range_to_csv(@users), filename: "Visting-reports-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def by_date_range_to_csv(_users)
    CSV.generate do |csv|
      csv << [ "TsE","Visit Category","Vendor",'Vendor Address','Visiting remarks','Visting reason','Exception status','Day','In Time','Out Time','Device Id','Recorded At','Synced At']
      _users.each do |object|
        csv << ["#{object.profile.full_name} (Ph: #{object.profile.contact_no})",'','','','','','','','','','','','','']
        visiting_histories = VisitingHistory.by_user(object.id).by_recorded_at(@from_datetime,@to_datetime).by_visited_entity_type("Vendor")
        work_statuses = UserWorkStatus.by_user(object.id).by_recorded_at(@from_datetime,@to_datetime)
        visiting_histories.each do |vh|
        	_vendor=Vendor.find(vh.visited_entity_id)
          vendor_name = _vendor.name.present? ? "#{_vendor.name}" : '-'
          vendor_address = _vendor.address.present? ? _vendor.address : '-'
          csv << ["#{object.profile.full_name} (Ph: #{object.profile.contact_no})",'Visiting Reports',vendor_name,vendor_address,vh.visiting_remarks,vh.visting_reason,'',vh.day,vh.in_time.strftime("%I:%M %p"),vh.out_time.strftime("%I:%M %p"),vh.device_id,vh.recorded_at.strftime("%d-%m-%Y, %I:%M %p"),vh.created_at.strftime("%d-%m-%Y, %I:%M %p")]
        end
        work_statuses.each do |ws|
          csv << ["#{object.profile.full_name} (Ph: #{object.profile.contact_no})",'Exception Status','_','_',ws.remarks,'_',ws.work_status,ws.recorded_at.strftime("%A"),'_','_',ws.device_id,ws.recorded_at.strftime("%d-%m-%Y, %I:%M %p"),ws.created_at.strftime("%d-%m-%Y, %I:%M %p")]
        end  
      end
    end
  end 

  def by_date_product_pricing
    if params[:product_id].present?
      @products = Product.set_product_id_in([params[:product_id]])
    else
      product_ids = VendorProductPrice.uniq.pluck(:product_id) 
      @products = Product.set_product_id_in(product_ids)
    end

    smart_listing_create :vendor_product_list, @products, partial: "se_reports/se_product_list"
    respond_to do |format|
      format.html
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data by_date_product_pricing_to_csv(@products), filename: "Pricing-reports-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def by_date_product_pricing_to_csv(_products)
    CSV.generate do |csv|
      csv << ["Product","Vendor","Sourcing Exectuve","Unit Price",'Supply Quantity','Agreed Quantity','Delivery Charge','Total Price','Valid till','Recorded At','Synced At']
      _products.each do |object|
        pricing_reports = VendorProductPrice.by_product(object.id).by_recorded_at("#{params[:from_date]}","#{params[:to_date]}")
        pricing_reports.each do |pp|
        	_sexc=User.find_by_id(pp.visited_by) 
          csv_arr=[]

          csv_arr.push("#{object.name}")
          csv_arr.push(pp.vendor.name)
          csv_arr.push(_sexc.profile.full_name)
          pp.unit_price.present? ? csv_arr.push(pp.unit_price.round(2)) : csv_arr.push("-")
          pp.quantity.present? ? csv_arr.push(pp.quantity) : csv_arr.push("-")
          pp.total_agreed_qty.present? ? csv_arr.push(pp.total_agreed_qty) : csv_arr.push("-")
          pp.delivery_cost.present? ? csv_arr.push(pp.delivery_cost.round(2)) : csv_arr.push("-")
          pp.total_agreed_qty.present? && pp.unit_price.present? ? csv_arr.push((pp.total_agreed_qty*pp.unit_price).round(2)) : csv_arr.push("-")
          csv_arr.push(pp.delivery_ends.strftime("%Y-%m-%d %I:%M:%p"))
          csv_arr.push(pp.recorded_at.strftime("%Y-%m-%d %I:%M:%p"))
          csv_arr.push(pp.updated_at.strftime("%Y-%m-%d %I:%M:%p"))

          csv << csv_arr
        end
      end
    end
  end
 
  private

  def set_module_details
    @module_id = "reports"
    @module_title = "SE Report"
  end 
end
