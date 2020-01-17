class TspReportsController < ApplicationController
  layout "material"
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include SaleReportsHelper
  include TspReportsHelper
  include ApplicationHelper
  include OrdersHelper
  before_filter :set_module_details
  before_filter :set_timerange, only: [:by_date_range, :day_by_day_order_reports,:day_by_day_shop_order_report, :shop_wise_order_summary_report, :shop_commission_report, :invoice_upload_report, :tse_sumary_report, :shop_wise_sales_report, :plant_wise_dispatch_report, :tse_sales_report, :district_wise_sales_report]


  def index
    child_unit_id_list =child_units([],current_user.unit)
    child_units = Unit.set_id_in(child_unit_id_list)
    child_units.each do |cu|
      puts cu.inspect
    end
    @collection = ["North America",["United States",["inner"]],["Canada",["inner"]]]

    # @units = Unit.by_unittype(3).order("unit_name asc")
    @units = child_units
    respond_to do |format|
      format.html
      format.json { render json: @menu_cards }
    end
  end
  
  def beneficiary_report
    # user = User.find(current_user.id)
    # has_child = User.has_child(user.id)
    # if has_child
    #   # @resources = get_sale_persons_for_user(user.id,[])
    #   @resources = get_user_resources(user.id)
    # else
    #   @resources = UserResource.where("user_id=?",current_user.id).uniq_by(&:resource_id)
    # end
    @resources = get_user_resources(current_user.id,nil,params[:from_date],params[:to_date])
    @resources = @resources.filter_by_string(params[:resource_filter]) if params[:resource_filter].present?
   

    # @resources = Kaminari.paginate_array(@resources)
    puts "total resources = #{@resources.length}"
    smart_listing_create :beneficiaries, @resources, partial:"tsp_reports/resource_beneficiaries_smart_list", page_sizes:[10]
    respond_to do |format|
      format.js
      format.html
      format.csv{ send_data beneficiary_commission_report_to_csv(@resources,params[:from_date],params[:to_date]), filename: "Beneficiary_commission-reports-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end
  
  def by_date_range
    if params[:user_id].present?
      @users = User.by_id(params[:user_id])
    else  
      @roll_arr = Array.new
      sale_person_role = Role.find_by_name("sale_person")
      @roll_arr.push(sale_person_role.id)
      @unit_arr = params['unit_ids'] if params['unit_ids'].present?
      @unit_arr = @unit_arr.reject { |c| c.empty? } if @unit_arr.present?
      
      @users = User.set_role(@roll_arr)
      if current_user.child_users.present?
        if @unit_arr.present?
          @users = @users.set_unit(@unit_arr).by_status(1).order(:unit_id)
          @users = @users.by_name(params[:tse_filter]).uniq if params[:tse_filter].present?
        else
          @users = User.set_role(@roll_arr).by_unit(current_user.unit_id).by_status(1).order(:unit_id)
        end
      else
        @users = User.where("id=?",current_user.id)
      end
    end
    smart_listing_create :user_list, @users, partial: "tsp_reports/tsp_list"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data by_date_range_to_csv(@users), filename: "Visting-reports-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def day_by_day_order_reports
    # params[:unit_ids].each do |unit_id|
    #   sale_persons_by_unit(unit_id)
    # end
    @report_type_filteration= ""
    @report_type_filteration = params[:report_type_filteration] if params[:report_type_filteration].present?
    if current_user.child_users.present?
      if params[:user_id].present?
        @users = User.by_id(params[:user_id])  
      else  
        @roll_arr = Array.new
        sale_person_role = Role.find_by_name("sale_person")
        @roll_arr.push(sale_person_role.id)
        if  params[:unit_ids].present?
          @users = User.set_role(@roll_arr).set_unit(params[:unit_ids]).by_status(1).order(:unit_id)
          @users = @users.by_name(params[:tse_filter]).uniq if params[:tse_filter].present?
        else
          @users = User.set_role(@roll_arr).by_unit(current_user.unit.id).by_status(1).order(:unit_id)
        end
      end
    else
      @users = User.where("id=?",current_user.id)
    end
    smart_listing_create :tsp_order_list, @users, partial: "tsp_reports/tsp_order_list"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data day_by_day_order_reports_to_csv(@users,@report_type_filteration), filename: "tse-orders-reports-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def day_by_day_shop_order_report
    @resources = Resource.by_unit(current_user.unit.id)
    @resources = Resource.by_unit_list(params[:unit_ids]) if params[:unit_ids].present?
    @resources = @resources.set_id(params[:resource_id]) if params[:resource_id].present?
    @resources = @resources.filter_by_string(params[:resource_filter]) if params[:resource_filter].present?    
    smart_listing_create :shop_order_list, @resources, partial: "tsp_reports/shop_order_list"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data day_by_day_shop_order_report_to_csv(@resources), filename: "day-by-day-shop-order-reports-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def shop_wise_order_summary_report
    @report_mode = params[:report_mode].present? ? params[:report_mode] : 'delivery_date'
    @resources = Resource.by_unit(current_user.unit.id)
    @resources = Resource.by_unit_list(params[:unit_ids]) if params[:unit_ids].present?
    @resources = @resources.set_id(params[:resource_id]) if params[:resource_id].present?
    @resources = @resources.filter_by_string(params[:resource_filter]) if params[:resource_filter].present?
    smart_listing_create :delivery_date_wise_order_list, @resources, partial: "tsp_reports/delivery_date_wise_order_list"
    
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data shop_wise_order_summary_report_to_csv(@resources,@report_mode,params[:unit_ids]), filename: "order-summary-reports-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end

  def shop_sumary_report
    #_unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    #@resources = Resource.active_only.by_unit(_unit_id)
    @resources = Resource.by_unit(current_user.unit.id)
    @resources = Resource.by_unit_list(params[:unit_ids]) if params[:unit_ids].present?
    @resources = @resources.set_id(params[:resource_id]) if params[:resource_id].present?
    @resources = @resources.filter_by_string(params[:resource_filter]) if params[:resource_filter].present?
      
    smart_listing_create :shop_sumary, @resources, partial: "tsp_reports/shop_sumary"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data shop_sumary_report_to_csv(@resources), filename: "Shop-summary-reports.csv" }
    end
  end

  def tse_sumary_report
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @roll_arr = Array.new
    sale_person_role = Role.find_by_name("sale_person")
    @roll_arr.push(sale_person_role.id)
    if current_user.child_users.present?
      if  params[:unit_ids].present?
        @users = User.set_role(@roll_arr).set_unit(params[:unit_ids]).by_status(1).order(:unit_id)
        @users = @users.by_name(params[:tse_filter]).uniq  if params[:tse_filter].present?
      else
        @users = User.set_role(@roll_arr).by_unit(current_user.unit.id).by_status(1).order(:unit_id) 
      end
    else
      @users = User.where("id=?",current_user.id) 
    end
    smart_listing_create :tse_sumary_list, @users, partial: "tsp_reports/tse_sumary_list"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data tse_sumary_report_to_csv(@users), filename: "tse_sumary_report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end
  end
  def tse_sales_report
    @from_date = @from_datetime
    @to_date = @to_datetime
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @roll_arr = Array.new
    sale_person_role = Role.find_by_name("sale_person")
    @roll_arr.push(sale_person_role.id)
    if current_user.child_users.present?
      if  params[:unit_ids].present?
        @users = User.set_role(@roll_arr).set_unit(params[:unit_ids]).by_status(1).order(:unit_id)
        @users = @users.by_name(params[:tse_filter]).uniq  if params[:tse_filter].present?
      else
        @users = User.set_role(@roll_arr).by_unit(current_user.unit.id).by_status(1).order(:unit_id) 
      end
    else
     @users = User.where("id=?",current_user.id) 
    end
    @stores = Store.set_unit_in(params[:unit_ids])
    smart_listing_create :tsp_sale_report, @users, partial: "tsp_reports/tsp_sale_report_smart_list"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data tse_sales_report_csv(@users,@from_date,@to_date,params[:store_id]), filename: "tsp_sale_report_#{params[:from_date]}-#{params[:to_date]}.csv" }
    end
  end

  def shop_database
    # _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @resources = Resource.by_unit(current_user.unit.id)
    @resources = Resource.by_unit_list(params[:unit_ids]) if params[:unit_ids].present?
    @resources = @resources.filter_by_string(params[:resource_filter]) if params[:resource_filter].present?
    smart_listing_create :shop_database, @resources, partial: "tsp_reports/shop_database"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data shop_database_to_csv(@resources), filename: "shop_database.csv" }
    end
    
  end

  def shop_commission_report
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @resources = get_user_resources(current_user.id,nil,params[:from_date],params[:to_date])
    @resources = @resources.filter_by_string(params[:resource_filter]) if params[:resource_filter].present?
    smart_listing_create :shop_commission_list, @resources, partial: "tsp_reports/shop_commission_list", page_sizes: [2]
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
    end
  end

  def invoice_upload_report
    @unit_id = params[:unit_ids].present? ? params[:unit_ids] : current_user.unit_id
    _store_ids = current_user.stores.map { |store| store.id } if current_user.stores.present?
    @sales = Bill.valid_bill.set_unit_in(@unit_id).order("recorded_at asc")
    @sales = @sales.by_recorded_at(@from_datetime,@to_datetime) if params[:from_date].present?
    @sales = @sales.by_stores(_store_ids) if _store_ids.present?
    @total_qty = @sales.map { |bill|bill.orders.map { |order|order.order_details.map { |order_detail|order_detail.quantity}.sum}}
    @total_qty = @total_qty.flatten
    smart_listing_create :invoice_by_date, @sales, partial: "tsp_reports/invoice_by_date_smartlist",default_sort: {recorded_at: "asc"}
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data store_orders_to_csv(@sales), filename: "plant-orders-report-of-#{params[:from_date]}.csv" }
    end
  end

  def shop_wise_sales_report
    #below two lines of code can fetch all the resources associated with the unit ids coming through params
    # @resources = Resource.by_unit(current_user.unit.id)
    # @resources = Resource.by_unit_list(params[:unit_ids]) if params[:unit_ids].present?
    if params[:resource_filter].present?
      @resources = Resource.by_unit_list(params[:unit_ids]).name_like(params[:resource_filter])
    elsif params[:store_id].present?
      resource_ids = Order.set_store_id(params[:store_id]).by_recorded_at(@from_datetime,@to_datetime).by_deliverable_type('Resource').select("deliverable_id").uniq.pluck(:deliverable_id)
      @resources = Resource.set_id_in(resource_ids)
    else
      orders = Order.by_unit_id(current_user.unit.id)
      orders = Order.set_unit_in(params[:unit_ids]) if params[:unit_ids].present?
      resource_ids = orders.by_recorded_at(@from_datetime,@to_datetime).order(:deliverable_id).by_deliverable_type('Resource').select("deliverable_id").uniq.pluck(:deliverable_id)
      puts "shop wise rsource count : #{resource_ids.length}"
      @resources =  Resource.set_id_in(resource_ids)
    end
    sale_persons = get_sale_persons_for_user(current_user.id,[])
    resource_list_from_user_resource = UserResource.by_users(sale_persons).by_date_range(params[:from_date],params[:to_date]).select(:resource_id).uniq.pluck(:resource_id)
    @resources = @resources.set_id_in(resource_list_from_user_resource)
    @stores = Store.set_unit_in(params[:unit_ids]) if params[:unit_ids].present?
    smart_listing_create :shop_sales,@resources,partial:"tsp_reports/shop_sales_smart_list"
    respond_to do |format|
      format.html
      format.js
      format.csv{send_data shop_wise_sales_report_csv(@resources,@from_datetime,@to_datetime,params[:store_id]),filename:"shop_wise_sales_report_#{params[:from_date]}_#{params[:to_date]}.csv"}
    end
  end
  
  def plant_wise_dispatch_report
    if params[:store_id].present?
      @store_details = Store.where("id=?",params[:store_id])
    else
      store_ids = Order.by_recorded_at(@from_datetime,@to_datetime).set_unit_in(params[:unit_ids]).select("store_id").uniq.pluck(:store_id)
      @store_details = Store.set_id_in(store_ids)
    end
    @stores = Store.set_unit_in(params[:unit_ids])
    smart_listing_create :plant_wise_dispatch_list,@store_details,partial:"tsp_reports/plant_wise_dispatch_report_smart_list"
    respond_to do |format|
      format.html
      format.js
      format.csv{send_data plant_wise_dispatch_report_csv(@store_details,@from_datetime,@to_datetime), filename:"plant_wise_dispatch_report_#{params[:from_date]}_#{params[:to_date]}.csv"}
    end
  end
  
  def sale_person_target_report   #SALE PERSON ACTUAL TARGETS VS TARGETS FULLFILLED
    from_date , to_date = Date.parse(params[:from_month]) , Date.parse(params[:to_month]).end_of_month
    @from_month, @to_month = Date.parse(params[:from_month]).month, Date.parse(params[:to_month]).month
    _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @roll_arr = Array.new
    sale_person_role = Role.find_by_name("sale_person")
    @roll_arr.push(sale_person_role.id)
    if  params[:unit_ids].present?
      @users = User.set_role(@roll_arr).set_unit(params[:unit_ids]).by_status(1).order(:unit_id)
      @users = @users.by_name(params[:tse_filter]).uniq  if params[:tse_filter].present?
    else
      @users = User.set_role(@roll_arr).by_unit(current_user.unit.id).by_status(1).order(:unit_id) 
    end
    tsp_user_ids = @users.pluck(:id)
    @user_targets = UserTarget.by_start_end_date(from_date,to_date).by_tsp_ids(tsp_user_ids)
    # smart_listing_create :sale_person_target, @user_targets , :partial=> "tsp_reports/sale_person_target_report_smart_list"
    respond_to do |format|
      format.html
      format.csv{send_data sale_person_target_report_csv(current_user,@from_month,@to_month),filename:"sale_person_target_report_#{@from_month}.csv"}
    end
  end

  def district_wise_sales_report 
    @all_districts,@district_without_paginate = fetch_all_districts
    @unit_ids = params[:unit_ids]
    @stores = Store.set_unit_in(params[:unit_ids])
    store_id = params[:store_id].present? ? params[:store_id] : ''
    smart_listing_create :district_wise_sales_list, @all_districts, partial:"tsp_reports/district_wise_sales_report_smartlist", page_sizes:[10]
    puts @district_without_paginate
    respond_to do |format|
      format.html
      format.js
      format.csv{send_data district_wise_sales_report_csv(@district_without_paginate,@unit_ids,@from_datetime,@to_datetime,store_id), filename:"district_wise_sales_report_#{params[:from_date]}_#{params[:to_date]}.csv"}
    end
  end
  
  def shop_target_report #shop wise target vs actual shop sale

  	@from_date , @to_date = Date.parse(params[:from_month]) , Date.parse(params[:to_month]).end_of_month
 	 	@from_month, @to_month = Date.parse(params[:from_month]).month, Date.parse(params[:to_month]).month
 	 	resource_id = ResourceTarget.by_month_range(@from_month,@to_month).uniq.pluck(:resource_id)
  	@resources = Resource.set_id_in(resource_id)
  	@resources = @resources.filter_by_string(params[:shop_filter]) if params[:shop_filter].present?
    smart_listing_create :shops_target_list,@resources,:partial=>"tsp_reports/shops_target_list_smart_list"
  	respond_to do  |format|
  		format.html
  		format.js
  		format.csv{send_data shop_target_report_csv(@resources,@from_month,@to_month),:filename=>"shop_target_report_#{@from_month}_#{@to_month}.csv"}
  	end
  end
  
  private
  def fetch_all_districts
    file_path = Rails.root.join("public", "District Segregation based on license.csv")
    all_districts = Array.new
    CSV.foreach(file_path,headers:true) do |row|
      flag = false
      all_districts.each do |dist|
        if dist[:district_name] == row['district_name']
          dist[:district_id].push(row['district_id'])
          flag = true
        end
      end
      if flag == false
        district_details = {}
        district_details[:district_id] = [row['district_id']]
        district_details[:district_name] = row['district_name']
        all_districts.push district_details
      end
    end
    return [Kaminari.paginate_array(all_districts),all_districts]
  end
  def set_module_details
    @module_id = "reports"
    @module_title = "TsE Report"
  end 

  def by_date_range_to_csv(_users)
    CSV.generate do |csv|
      csv << [ "TsE","Visit Category","Resource","Address",'Customer','Customer State','Visiting remarks','Visting reason','Exception status','Day','In Time','Out Time','Device Id','Recorded At','Synced At']
      _users.each do |object|
        csv << ["#{object.profile.full_name} (Ph: #{object.profile.contact_no}) (Unit: #{object.unit.unit_name})",'','','','','','','','','','','','','']
        visiting_histories = VisitingHistory.by_user(object.id).by_recorded_at(@from_datetime,@to_datetime)
        work_statuses = UserWorkStatus.by_user(object.id).by_recorded_at(@from_datetime,@to_datetime)
        visiting_histories.each do |vh|
          customer_name = vh.customer.present? ? "#{vh.customer.customer_profile.firstname} #{vh.customer.customer_profile.lastname}" : '_'
          customer_address = vh.customer.present? ? "#{vh.customer.addresses.first.delivery_address}" : vh.visited_entity.address
          visited_entity_name='-'
          resource_unique_identity_no = ''
          if vh.visited_entity.present?
            visited_entity_name = vh.visited_entity.name
            resource_unique_identity_no = vh.visited_entity_type == 'resource' && vh.visited_entity.unique_identity_no.present? ? "(#{vh.visited_entity.unique_identity_no})" : ""
          end
          if vh.customer.present?
            customer_state = vh.customer.customer_state.present? ? vh.customer.customer_state.name : '_'
          else
            customer_state = "-"  
          end  
          csv << ["#{object.profile.full_name} (Ph: #{object.profile.contact_no})",'Visiting Reports',"#{visited_entity_name} #{resource_unique_identity_no}",customer_address,customer_name,customer_state,vh.visiting_remarks,vh.visting_reason,'',vh.day,vh.in_time.strftime("%I:%M %p"),vh.out_time.strftime("%I:%M %p"),vh.device_id,vh.recorded_at.strftime("%d-%m-%Y, %I:%M %p"),vh.created_at.strftime("%d-%m-%Y, %I:%M %p")]
        end
        work_statuses.each do |ws|
          csv << ["#{object.profile.full_name} (Ph: #{object.profile.contact_no})",'Exception Status','_','_','_',ws.remarks,'_',ws.work_status,ws.recorded_at.strftime("%A"),'_','_',ws.device_id,ws.recorded_at.strftime("%d-%m-%Y, %I:%M %p"),ws.created_at.strftime("%d-%m-%Y, %I:%M %p")]
        end  
      end
    end
  end  

  def day_by_day_order_reports_to_csv(_users,filter_type)
    CSV.generate do |csv|
      csv << [ "TsE","Invoice No","Distributer","Order Id","Deliver To",'Item Name','HSN CODE','QTY',"unit",'Device Id','Delivery Date','Recorded At','Synced At']
      _users.each do |user|
        csv << ["#{user.profile.full_name} (Ph: #{user.profile.contact_no}) (Unit: #{user.unit.unit_name})",'','','','','','','','','','','']
        # order_details_id_for_order = Order.by_consumer_id(user.id).by_consumer_type('User').by_recorded_at(@from_datetime,@to_datetime).not_canceled.map{|order| order.order_details.map{|od| od.id}}.flatten
        # orderdetails = OrderDetail.where(:id => order_details_id_for_order,:trash=>0)
        orderdetails = []
        store_requisitions = []
        if filter_type == "orders"
          orderdetails = get_order_details_for_tsp(user.id,@from_datetime,@to_datetime)
        elsif filter_type == "requisition"
          store_requisitions = get_requisitions_for_tsp(user.id,@from_datetime,@to_datetime)
        else
          orderdetails = get_order_details_for_tsp(user.id,@from_datetime,@to_datetime)
          store_requisitions = get_requisitions_for_tsp(user.id,@from_datetime,@to_datetime)
        end
        orderdetails.each do |object|
          invoice_id = object.order.bill.present? ? object.order.bill.serial_no : '-'
          store_name = object.order.store.present? ? object.order.store.name : '-'
          customer = ""
          customer = ",#{object.order.customer.customer_profile.firstname}" "#{object.order.customer.customer_profile.lastname},""(Ph:#{object.order.customer.mobile_no})" if object.order.customer.present?
          unique_identity_no = object.order.deliverable.unique_identity_no.present? ? "(#{object.order.deliverable.unique_identity_no})" : ""
          csv << ["#{user.profile.full_name} (Ph: #{user.profile.contact_no}) (Unit: #{user.unit.unit_name})",invoice_id,store_name,object.order_id,"#{object.order.resource_type}: ""#{object.order.deliverable.name} \n #{unique_identity_no} #{customer}",object.product_name,object.hsn_code,"#{object.quantity.round(0)}","(#{object.product.basic_unit})",object.order.device_id,object.order.delivary_date.strftime("%d-%m-%Y, %I:%M %p"),object.recorded_at.strftime("%d-%m-%Y, %I:%M %p"),object.created_at.strftime("%d-%m-%Y, %I:%M %p")]
        end
        if store_requisitions.present?
          store_requisitions.each do |requisition_meta|
            estimated_deliver_date = 'N/A'
            csv << ["#{user.profile.full_name} (Ph: #{user.profile.contact_no}) (Unit: #{user.unit.unit_name})","N/A",requisition_meta.store_requisition.from_store.name,"#{requisition_meta.store_requisition.id}(requisition)",requisition_meta.store_requisition.destination_store.name ,requisition_meta.product.name,requisition_meta.product.hsn_code,"#{requisition_meta.product_ammount.round(0)}","#{requisition_meta.product.basic_unit}","N/A",estimated_deliver_date,requisition_meta.store_requisition.created_at.strftime("%d-%m-%Y, %I:%M %p"),"N/A"]
          end
        end
      end
    end
  end

  def day_by_day_shop_order_report_to_csv(_resources)
    CSV.generate do |csv|
      csv << [ "Resource","District Name","Invoice No","Distributer","Order Id","Item Name",'HSN CODE','QTY','unit','TsE','Device Id','Delivery Date','Recorded At','Synced At']
      _resources.each do |resource|
        _district_name = get_district_name_by_resource(resource)
        _resource_customer = resource.customer.present? ? "#{resource.customer.customer_profile.firstname}" "#{resource.customer.customer_profile.lastname}" : '.'
        _resource_phone = resource.customer.present? ? "#{resource.customer.mobile_no}": '.'
        csv << ["#{resource.name.humanize} \n (#{resource.unique_identity_no}) \n ( #{_resource_customer}) (Ph: #{_resource_phone}) (Unit: #{resource.unit.unit_name})",_district_name,'','','','','','','','','','','']
        order_details_id_for_order = Order.resource_orders(resource.id).by_consumer_type('User').by_recorded_at(@from_datetime,@to_datetime).not_canceled.map{|order| order.order_details.map{|od| od.id}}.flatten
        orderdetails = OrderDetail.where(:id => order_details_id_for_order,:trash=>0)
        orderdetails.each do |object|
          store_name = object.order.store.present? ? object.order.store.name : '-'
          invoice_id = object.order.bill.present? ? object.order.bill.serial_no : '-'
          csv << ["#{resource.name.humanize} \n(#{resource.unique_identity_no}) \n ( #{_resource_customer}) (Ph: #{_resource_phone}) (Unit: #{resource.unit.unit_name})",_district_name,invoice_id,store_name,object.order_id,object.product_name,object.hsn_code,"#{object.quantity.round(0)}","#{object.product.basic_unit}","#{object.order.consumer.profile.full_name} (Ph: #{object.order.consumer.profile.contact_no})",object.order.device_id,object.order.delivary_date.strftime("%d-%m-%Y, %I:%M %p"),object.recorded_at.strftime("%d-%m-%Y, %I:%M %p"),object.created_at.strftime("%d-%m-%Y, %I:%M %p")]
        end
      end
    end
  end

  def shop_wise_order_summary_report_to_csv(_resources,report_mode,unit_id)
    CSV.generate do |csv|
      if report_mode == 'delivary_date'
        csv << [ "Resource","District","Item Name","HSN CODE",'Total QTY','unit','Delivery Date']
      else
        csv << [ "Resource","District","Item Name","HSN CODE",'Total QTY','unit','From Date','To Date']
      end  
      _resources.each do |resource|
        _district_name= get_district_name_by_resource(resource)
        _resource_customer = resource.customer.present? ? "#{resource.customer.customer_profile.firstname}" "#{resource.customer.customer_profile.lastname}" : '.'
        _resource_phone = resource.customer.present? ? "#{resource.customer.mobile_no}": '.'
        if report_mode == 'delivary_date'
          csv << ["#{resource.name.humanize} \n (#{resource.unique_identity_no}) \n ( #{_resource_customer}) (Ph: #{_resource_phone})",_district_name,'','','','','','']
        else
          csv << ["#{resource.name.humanize} \n (#{resource.unique_identity_no}) \n ( #{_resource_customer}) (Ph: #{_resource_phone})",_district_name,'','','','','','','']
        end  
        
        order_details_id_for_order = Order.resource_orders(resource.id).by_unit_id(resource.unit_id).by_recorded_at(@from_datetime,@to_datetime).not_canceled.map{|order| order.order_details.map{|od| od.id}}.flatten
        if report_mode == 'delivery_date'
          orderdetails = OrderDetail.select("date(delivary_date) as date, sum(quantity) as total_sale, sum(subtotal) as total_price,product_name,product_id").group("date(delivary_date),product_name,product_id").where(:id => order_details_id_for_order,:trash=>0)
        else
          orderdetails = OrderDetail.select("sum(quantity) as total_sale, sum(subtotal) as total_price,product_name,product_id").group("product_name,product_id").where(:id => order_details_id_for_order,:trash=>0)
        end
        orderdetails.each do |object|
          product = Product.find(object["product_id"])
          if report_mode == 'delivary_date'
            csv << ["#{resource.name.humanize} \n (#{resource.unique_identity_no}) \n ( #{_resource_customer}) (Ph: #{_resource_phone})",_district_name,object["product_name"],"#{product.hsn_code}","#{object['total_sale'].to_f.round(0)}" ," #{product.basic_unit}",object["date"]]
          else
            csv << ["#{resource.name.humanize} \n (#{resource.unique_identity_no}) \n ( #{_resource_customer}) (Ph: #{_resource_phone})",_district_name,object["product_name"],"#{product.hsn_code}","#{object['total_sale'].to_f.round(0)}" , " #{product.basic_unit}",object["date"]]
          end  
        end
      end
    end
  end  

  def shop_sumary_report_to_csv(_resources)
    CSV.generate do |csv|
      csv << ["Resource","District", "Resource State", "Last Visited by", "Last Visited Date", "Aging Days", "Recorded Date", "Synced Date"]
      _resources.each do |resource|
        _district_name = get_district_name_by_resource(resource)
        visiting_history = last_visiting_history(resource)
        _aging_day = aging_days(resource)
        if resource.customer.present? 
          if resource.customer.customer_state.present?
            state = resource.customer.customer_state.name
          else
            state = 'No State'
          end 
        else
          state = 'Has no Customer'
        end  
        if visiting_history.present?
          visited_by = "#{visiting_history.user.profile.firstname}" " #{visiting_history.user.profile.lastname}"
          last_visit_date = visiting_history.recorded_at.strftime("%d-%m-%Y, %I:%M %p")
          recorded_at = visiting_history.recorded_at.strftime("%d-%m-%Y, %I:%M %p")
          synced_date = visiting_history.created_at.strftime("%d-%m-%Y, %I:%M %p")
        else
          visited_by = 'Not Visited'
          last_visit_date = 'Not Visited'
          recorded_at = resource.created_at.strftime("%d-%m-%Y, %I:%M %p")
          synced_date = resource.created_at.strftime("%d-%m-%Y, %I:%M %p")
        end
        csv << ["#{resource.name}  (#{resource.unique_identity_no})",_district_name,"#{state}","#{visited_by}","#{last_visit_date}","#{_aging_day} Days","#{recorded_at}","#{synced_date}"]
      end  
    end
  end

  def tse_sumary_report_to_csv(_users)
    CSV.generate do |csv|
      # csv << ["TsE", "Allocated shop", "Unique Pending shop", "Unique Allocated visited shop", "Completion Percentage(%)", "Total Allocated visited shop", "Unique Unallocated visited shop","Total Unallocated visited shop"]
      csv << ["TsE", "Total Allocated Shop", "Completed", "Completion Percentage(%)", "Total Allocated Visit", "Completed(As per PJP)", "Completion Percentage","Visit(without PJP)"] 
      _users.each do |object|
        alloted_details = get_unique_alloted_details_of_tse(object,@from_date,@to_date,@from_datetime,@to_datetime)
        # csv << ["#{object.profile.firstname}" " #{object.profile.lastname}", "#{alloted_details[:alloted_count]}", "#{alloted_details[:pending_visit_allocated_shop_Unique]}", "#{alloted_details[:visti_allocated_shop_Unique]}", "#{alloted_details[:completion_percentage]}", "#{alloted_details[:visit_allocated_shop_total]}", "#{alloted_details[:visit_unallocated_shop_unique]}","#{alloted_details[:visit_unallocated_shop_total]}"] 
        csv << ["#{object.profile.firstname}" " #{object.profile.lastname}", alloted_details[:total_uniq_alloted_shop], alloted_details[:total_uniq_alloted_shop_completed], alloted_details[:total_uniq_alloted_shop_completed_percentage], alloted_details[:pjp_allocation], alloted_details[:pjp_allocation_wise_completed], alloted_details[:pjp_allocation_percentage], alloted_details[:visit_without_pjp]]
      end  
    end  
  end

  def shop_database_to_csv(_resources)
    CSV.generate do |csv|
      csv << ["Shop Name", "District","Owner Name", "Contact No", "Email", "Address","Locality","PinCode", "Pan no", "Gstn","Allocated TsE","Created Date"] 
      _resources.each do |resource|
        allcated_tse = allocated_tses(resource)
        _district_name = get_district_name_by_resource(resource)
        if resource.customer.present? 
          if resource.customer.customer_profile.customer_name.present?
            owner_name = "#{resource.customer.customer_profile.customer_name}"
          else  
            owner_name = "#{resource.customer.customer_profile.firstname}" " #{resource.customer.customer_profile.lastname}"
          end
          mobile_no = "#{resource.customer.mobile_no}"
          email = resource.customer.email != '' ? resource.customer.email : '-'
          if resource.customer.addresses.present?
            addresses = "#{resource.customer.addresses.last.delivery_address}" 
            pincode = "#{resource.customer.addresses.last.pincode}"
            locality = "#{resource.customer.addresses.last.locality}"
          else  
            addresses = '-'
            pincode = '-'
            locality = '-'
          end 
          pan_no = "#{resource.customer.customer_profile.pan_no}" 
          gstn = "#{resource.customer.gstin}"
          tses = "#{allcated_tse}"
        else
          owner_name = 'Has no Owner'
          mobile_no = 'Has no Owner'
          email = 'Has no Owner'
          addresses = 'Has no Owner'
          pincode = 'Has no Owner'
          pan_no = 'Has no Owner'
          gstn = 'Has no Owner'
          tses = 'Has no Owner'
          locality = 'Has no Owner'
        end  
        created_at = resource.created_at.strftime("%d-%m-%Y, %I:%M %p")
        csv << ["#{resource.name}  (#{resource.unique_identity_no})",_district_name," #{owner_name}", "#{mobile_no}", "#{email}", "#{addresses}","#{locality}","#{pincode}", "#{pan_no}", "#{gstn}", "#{tses}","#{created_at}"] 
      end  
    end 
  end

  def store_orders_to_csv(sales)
    CSV.generate do |csv|
      csv << ["Date", "Plant Name", "Invoice No", "Total Quantity in invoce"] 
      sales.each do |object|
        csv << ["#{object.recorded_at.strftime("%d-%m-%Y, %I:%M %p")}", "#{object.orders.first.store.name}", "#{object.orders.first.checksum}", "#{object.orders.first.order_details.sum(:quantity).to_f.round(0)}"] 
      end 
      csv << ["Summary Of Report"] 
      csv << ["Total No of Invoice", "Total qty", "Total Amnt"] 
      csv << ["#{@sales.count}", "#{@total_qty[0]}", "#{@sales.sum(:grand_total)}"] 
    end 
  end

  def beneficiary_commission_report_to_csv(resources,from_date,to_date)
    CSV.generate do |csv|
      csv << ["Resource name","Beneficiary name","Beneficiary type", "Commission percentage","Commission amount (INR)","bank account details","ifsc"]
      resources.each do |object|
        total_owner_commission_amount = get_commission_amount(object.id,"owner",from_date,to_date)
        total_csm_commission_amount = get_commission_amount(object.id,"csm",from_date,to_date)
        csv << ["#{object.name} (#{object.unique_identity_no})","","","",""]
        if object.beneficiaries.present?
          object.beneficiaries.each do |beneficiary|
            if beneficiary.beneficiary_type == "owner"
              _commission_amount = ((total_owner_commission_amount/100)*beneficiary.beneficiary_percentage.to_i).round(2)
            else
              _commission_amount = ((total_csm_commission_amount/100)*beneficiary.beneficiary_percentage.to_i).round(2)
            end
            csv << ["",beneficiary.name,beneficiary.beneficiary_type,beneficiary.beneficiary_percentage,_commission_amount,"#{beneficiary.bank_name}\n #{beneficiary.account_number}",beneficiary.ifsc]
          end
        end
      end
    end
  end
  def tse_sales_report_csv(users,from_date,to_date,store_id)
    CSV.generate do |csv|
      csv<<["user name","Manager Name","product name","quantity","product unit"]
      users.each do |user|
        manager_name = user.parent_user.present? ? user.parent_user.profile.full_name : 'N/A'
        csv<<[user.profile.full_name,manager_name,"","",""]
        group_order_details_for_tsp = get_group_order_details_for_tsp(user.id,from_date,to_date,store_id)
        if group_order_details_for_tsp.present?
          group_order_details_for_tsp.each do |order_details|
            csv<<[user.profile.full_name,manager_name,order_details.product_name,"#{order_details.quantity.to_f.round(0)}"," #{order_details.product.basic_unit}"]
          end
        end
      end
    end
  end
  def shop_wise_sales_report_csv(resources,from_date,to_date,store_id)
    CSV.generate do |csv|
      csv<<["shop name","district name","TSP name","item name","quantity sold","product unit"]
      resources.each do |resource|
        district_name = get_district_name_by_resource(resource)
        resource_name = resource.name.gsub("&","and")
        tsp = fetch_tsp(resource,params[:from_date],params[:to_date])
        tsp_name = tsp.present? ? "#{tsp.firstname} #{tsp.lastname}" : "-"
        order_details = fetch_resource_orders(resource,from_date,to_date,store_id)
        if order_details.present?
          order_details.each do |order_detail|
            csv <<["#{resource_name}\n(#{resource.unique_identity_no})",district_name,tsp_name,order_detail.product.name,"#{order_detail.total_quantity.to_i.round(0)}"," #{order_detail.product.basic_unit}"]
          end
        end
      end
    end
  end

  def plant_wise_dispatch_report_csv(store_obj,from_date,to_date)
    CSV.generate do |csv|
      csv<<["plant name","item name","total quantity","Despatch Quantity for the Year","Despatch Quantity for Last Year","product unit"]
      store_obj.each do |store|
        store_order_details,total_dispatch_quantity = fetch_store_order_details(store,from_date,to_date)
        csv<<[store.name,"",total_dispatch_quantity,"","",""]
        if  store_order_details.present?
          store_order_details.each do |order_detail|
          	current_year_product_dispatch,previous_year_product_dispatch = current_year_and_previous_year_product_dispatch(order_detail.product_id,store.id)
            csv<<["",order_detail.product.name,"#{order_detail.total_quantity.to_f.round(0)}","#{current_year_product_dispatch.to_f.round(0)}","#{previous_year_product_dispatch.to_f.round(0)}","#{order_detail.product.basic_unit}"]
          end
        end
      end
    end
  end
  def district_wise_sales_report_csv(all_districts,unit_ids,from_date,to_date,store_id='')
    puts all_districts.length
    CSV.generate do |csv|
      csv<<["District Name","Item Name","Despatch Quantity","Despatch Quantity for the Year","Despatch Quantity for last Year","Product Unit"]
      all_districts.each do |object|
        district_name = object[:district_name]
        district_id = object[:district_id]
        # district_resource_sales = UserSale.by_resource_ids(district_resource_ids).by_recorded_at_between(@from_datetime,@to_datetime)
        district_resources = Resource.set_district_ids_like(district_id).by_unit_list(unit_ids)
        district_resource_ids = district_resources.uniq.pluck(:id)
        district_resource_order_details = fetch_order_details_by_resources(district_resource_ids,from_date,to_date)
        district_resource_order_details = district_resource_order_details.by_store(store_id) if store_id != '' and district_resource_order_details.present?
        # selled_product_ids = district_resource_order_details.uniq.pluck(:product_id)
        # selled_products = Product.set_product_id_in(selled_product_ids)
        selled_products = district_resource_order_details
        if selled_products.present?
          selled_products.each do |product_sale|
            product = Product.find(product_sale.product_id)
            current_year_product_dispatch,previous_year_product_dispatch = current_year_and_previous_year_product_dispatch(product.id,'',district_resource_ids)
            csv << [ "#{district_name}", product.name, "#{product_sale.total_quantity.to_f.round(0)}", "#{current_year_product_dispatch.to_f.round(0)}", "#{previous_year_product_dispatch.to_f.round(0)}"," #{product.basic_unit}"]
          end
        else
          csv << [ "#{district_name}", "", "", "", "" ]  
        end
      end
    end
  end

  def sale_person_target_report_csv(current_user,from_month,to_month)
    CSV.generate do |csv|
      csv<<["user","role","product","actual target","actual sale","product unit"]
      user_targets = calculate_user_sale(current_user,from_month,to_month)
      user_targets.each do |user_target|
        csv<<user_target
      end
      child_user_data = nested_user_sale_report(current_user,from_month,to_month,csv)
    end
  end
  #recursive method call to get all the child user's targets and sales
  def nested_user_sale_report(user_obj,from_month,to_month,csv)
    if user_obj.child_users.present?
      user_obj.child_users.each do |user|
        child_user_targets = calculate_user_sale(user,from_month,to_month)
        child_user_targets.each do |child_user_target|
        	csv<<child_user_target
        end
        nested_user_sale_report(user,from_month,to_month,csv) 
      end
    else
      return []
    end
  end
  #calulate the user targets
  def calculate_user_sale(user_obj,from_month,to_month)
    user_target_array = Array.new()
    user_targets = user_obj.own_targets.by_month_range(from_month,to_month)
    user_target_row =Array.new
    user_target_row.push(user_obj.profile.full_name)
    user_target_row.push(user_obj.role.name.humanize)
    if user_targets.present?
      user_targets.each do |user_target|
        user_target.user_target_products.each do |user_target_product|
          user_sale = 0
          if user_obj.child_users.present?
            _user_lists = nested_child_users(user_obj,[])
            user_sale = UserSale.by_user_ids(_user_lists).by_recorded_at_month_range(from_month,to_month).sum(:quantity)
          else
            user_sale = UserSale.by_user_id(user_obj.id).by_recorded_at_month_range(from_month,to_month).sum(:quantity)
          end
          user_target_row.push(user_target_product.product.name)
          user_target_row.push("#{user_target_product.target_quantity.to_f.round(0)}")
          user_target_row.push(user_sale)
          user_target_row.push("#{user_target_product.product.basic_unit}")
        end
      end
    end
    user_target_array.push(user_target_row)
    return user_target_array
  end

  def shop_target_report_csv(resources,from_month,to_month)
  	CSV.generate do |csv|
  		csv<<["resource name","district name","tsp name","actual target","achieved target"]
  		resources.each do |resource|
  			district_name = get_district_name_by_resource(resource)
  			tsp = fetch_tsp(resource,@from_date,@to_date)
  			tsp = tsp.present? ? "#{tsp.firstname} #{tsp.lastname}" : "-" 
  			actual_target = get_resource_targets(resource,@from_month,@to_month)
  			achieved_target = get_achieved_target_for_resource(resource,@from_month,@to_month)
  			csv<<[resource.name,district_name,tsp,actual_target.to_f.round(0),achieved_target.to_f.round(0)]
  		end
  	end
  end
end