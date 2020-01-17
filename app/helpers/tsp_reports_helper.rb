module TspReportsHelper

	# Last Visting history for a resource
	def last_visiting_history resource
		_last_vs = resource.visiting_histories.last
		return _last_vs
	end

	# Aging day for resource visit
	def aging_days resource
		_last_vs = resource.visiting_histories.last
		if _last_vs.present?
			_aging_day = Date.today - Date.parse(_last_vs.recorded_at.strftime("%d-%m-%Y, %I:%M %p"))
		else
			_aging_day = Date.today - Date.parse(resource.created_at.strftime("%d-%m-%Y, %I:%M %p"))
		end	
		_aging_day = _aging_day.to_s.split("/")[0]
	end

	# Alloted resource of a tse with in date range
	def get_alloted_details_of_tse user,fromdate,todate
		visiting_details = {}
		@dates = (fromdate..todate).select { |date| date if Date.valid_date? *date.split('-').map(&:to_i)} 
		alloted_count 											= 0
		visti_allocated_shop_Unique 				= 0
		pending_visit_allocated_shop_Unique = 0
		completion_percentage								= 0
		visit_allocated_shop_total 					= 0
		visit_unallocated_shop_unique 			= 0
		visit_unallocated_shop_total				= 0
		@dates.each do |date|
			day 									 			 	= date.to_date.strftime("%A")
			_allocating_visited_shop 		 	= VisitingHistory.by_user(user.id).by_day(day).by_date(date).by_visiting_type('Assigned')
			_unallocating_visited_shop   	= VisitingHistory.by_user(user.id).by_day(day).by_date(date).by_visiting_type('Unassigned')
			alloted_count 								+= UserResource.by_user(user.id).by_day(day).count
			visti_allocated_shop_Unique 	+= _allocating_visited_shop.uniq_by(&:resource_id).count
			visit_allocated_shop_total		+= _allocating_visited_shop.count
			visit_unallocated_shop_unique += _unallocating_visited_shop.uniq_by(&:resource_id).count
			visit_unallocated_shop_total  += _unallocating_visited_shop.count
		end	
		visiting_details[:alloted_count] 												= alloted_count
		visiting_details[:visti_allocated_shop_Unique] 					= visti_allocated_shop_Unique
		visiting_details[:pending_visit_allocated_shop_Unique] 	= alloted_count - visti_allocated_shop_Unique
		visiting_details[:completion_percentage] 								= visti_allocated_shop_Unique != 0 ? ((visti_allocated_shop_Unique.to_f / alloted_count.to_f) * 100).round(2) : 0
		visiting_details[:visit_allocated_shop_total] 					= visit_allocated_shop_total
		visiting_details[:visit_unallocated_shop_unique] 				= visit_unallocated_shop_unique
		visiting_details[:visit_unallocated_shop_total] 				= visit_unallocated_shop_total
		return visiting_details
	end

  def get_unique_alloted_details_of_tse user,fromdate,todate,from_datetime,to_datetime
    visiting_details = {}
    total_pjp_allocation = UserResource.by_user(user.id).by_date_range(fromdate,todate)
    total_uniq_alloted_resouces = total_pjp_allocation.uniq.pluck(:resource_id)
    total_visited_shop = VisitingHistory.by_user(user.id).by_recorded_at(from_datetime,to_datetime).by_visited_entity_type("Resource")
    total_allocating_visited_shop = total_visited_shop.set_entity_ids(total_uniq_alloted_resouces)
    total_uniq_alloted_shop_completed = total_allocating_visited_shop.uniq_by(&:visited_entity_id)   
    #pjp_allocation_wise_completed = total_allocating_visited_shop.uniq { |obj| [obj[:day], obj[:visited_entity_id]] }   
    #total_day_wise_uniq_visited_shop = total_visited_shop.uniq { |obj|[ obj[:day], obj[:visited_entity_id]]

    total_day_wise_uniq_visited_shop = VisitingHistory.select("visited_entity_id, day, date(recorded_at) as date").group("date(recorded_at),visited_entity_id,day").by_user(user.id).by_recorded_at(from_datetime,to_datetime).by_visited_entity_type("Resource")
    pjp_allocation_wise_completed = total_day_wise_uniq_visited_shop.set_entity_ids(total_uniq_alloted_resouces)

    logger.debug total_visited_shop
    visiting_details[:total_uniq_alloted_shop]                        =  total_uniq_alloted_resouces.count
    visiting_details[:total_uniq_alloted_shop_completed]              =  total_uniq_alloted_shop_completed.count
    visiting_details[:total_uniq_alloted_shop_completed_percentage]   =  total_uniq_alloted_resouces.count != 0 ? ((total_uniq_alloted_shop_completed.count.to_f / total_uniq_alloted_resouces.count.to_f) * 100).round(2) : 0
    visiting_details[:pjp_allocation]                                 =  total_pjp_allocation.count
    visiting_details[:pjp_allocation_wise_completed]                  =  pjp_allocation_wise_completed.length
    visiting_details[:pjp_allocation_percentage]                      =  total_pjp_allocation.count != 0 ? ((total_allocating_visited_shop.count.to_f / total_pjp_allocation.count.to_f) * 100).round(2) : 0
    visiting_details[:visit_without_pjp]                              =  total_day_wise_uniq_visited_shop.length - pjp_allocation_wise_completed.length
    
    return visiting_details
  end

	# Get Allocated TsE of a resource
	def allocated_tses resource
	  _user_ids = resource.user_resources.pluck(:user_id).uniq
    _users = User.set_user(_user_ids)
    string = ''
    _users.each do |ur|
    string = string + "#{ur.profile.firstname}" " #{ur.profile.lastname}"
    string = string + ", " unless ur == _users.last 
    end
    return string
	end

	def  load_child_units_checkbox(unit_id,suffix)
    _unit = Unit.find(unit_id)
    concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none"], :style => "-webkit-user-drag: none;") {
      # concat(content_tag(:span, "--- "))
      #check_status = (current_user.unit_id != unit_id) ? false : true
      if current_user.role.name == "owner" 
        check_status = true
      else
        check_status = (current_user.unit_id != unit_id) ? false : true
      end 
      if _unit.unittype.unit_type_name.humanize == "Outlet"
        check_box_class = 'checkbox-outlet'
        valid_unit = _unit.id         
      elsif _unit.unittype.unit_type_name.humanize == "Owner"
        check_box_class = 'check'
        valid_unit = ''
      else
        check_box_class = 'checkbox-dc'
        valid_unit = ''
      end 
      concat (check_box_tag('unit_ids[]', valid_unit, check_status, :id => "#{_unit.id}", :class=>"#{suffix}_units-checkbox #{check_box_class}" ))
      concat (label_tag(_unit.id, _unit.unit_name))
      concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal"))
      _child_units = Unit.set_parent_unit(_unit.id).order("unit_name asc")
      if _child_units.present?
        # concat (content_tag(:li, class: ["divider"]){})
        concat (content_tag(:ul, class: ["collection-child"]) {
          concat(content_tag(:br))
          _child_units.each do |unit|
            load_child_units_checkbox(unit.id,suffix)    
          end
        })     
      end
    })
  end

  def get_commission_amount(resource_id,beneficiary_type,from_date,to_date)
  	user_sale = 0
    if beneficiary_type == "owner"
  		user_sale = UserSale.where("resource_id=? and created_at BETWEEN ? AND ?",resource_id,from_date,to_date).sum(:owner_commission)  
    else
  		user_sale = UserSale.where("resource_id=? and created_at BETWEEN ? AND ?",resource_id,from_date,to_date).sum(:thirdparty_commission)
    end
    puts "user sale #{user_sale}"
  	return user_sale
  end

  def units_checkbox(unit_id,prefix,check_class="")
    _unit = Unit.find(unit_id)
    concat (content_tag(:li, class: ["collection-item", "dismissable", "padding-r-none"], :style => "-webkit-user-drag: none;") {
      concat (check_box_tag('unit_ids[]', _unit.id, true, :id => "#{prefix}_#{_unit.id}", :class=>"units-checkbox #{check_class}" ))
      concat (label_tag("#{prefix}_#{_unit.id}", _unit.unit_name))
      concat(content_tag(:span, _unit.unittype.unit_type_name.humanize, :class => "m-label teal"))
      _child_units = Unit.set_parent_unit(_unit.id).order("unit_name asc")
      if _child_units.present?
        concat (content_tag(:ul, class: ["collection-child"]) {
          concat(content_tag(:br))
          _child_units.each do |unit|
            units_checkbox(unit.id,prefix,check_class)   
          end
        })     
      end
    })
  end
  def fetch_resource_orders(resource_obj,from_date,to_date,store_id=nil)
    if store_id == nil
     order_ids  = resource_obj.orders.by_recorded_at(from_date,to_date).pluck(:id)
    else
      order_ids  = resource_obj.orders.by_recorded_at(from_date,to_date).set_store_id(store_id).pluck(:id)
    end
    order_details  = OrderDetail.by_order_ids(order_ids)
    order_details = order_details.select("product_id,sum(quantity)as total_quantity,sum(subtotal)as total_price").group("product_id")
    
    return order_details
  end
  def fetch_tsp(resource_obj,from_date,to_date)
    user_resource = resource_obj.user_resources.by_date_range(from_date,to_date).last
    user = user_resource.present? ? user_resource.user.profile : ''
    return user
  end
  def fetch_store_order_details(store_obj,from_date,to_date)
    total_dispatch_quantity = 0
    order_ids = store_obj.orders.by_recorded_at(from_date,to_date).pluck(:id)
    order_details  = OrderDetail.by_order_ids(order_ids)
    total_dispatch_quantity = order_details.sum(:quantity)
    order_details = order_details.select("product_id,sum(quantity)as total_quantity,sum(subtotal)as total_price").group("product_id")
    return [order_details,total_dispatch_quantity]
  end
  def fetch_order_details_by_resources(resource_ids,from_date,to_date)
    orders = Order.set_resources(resource_ids).by_recorded_at(from_date,to_date)
    if orders.present?
      resources = orders.uniq(:deliverable_id)
      order_ids = orders.pluck(:id)
      order_details = OrderDetail.by_order_ids(order_ids)
      order_details = order_details.select("product_id,sum(quantity)as total_quantity").group("product_id")
    end
    return order_details
  end
  def get_district_name_by_resource(resource_obj)
    if resource_obj.unique_identity_no.present?
      district_id = resource_obj.unique_identity_no.slice(0..1)
      logger.debug district_id
      logger.debug "here"
      file_path = Rails.root.join("public", "District Segregation based on license.csv")
      CSV.foreach(file_path,headers:true) do |row|
        logger.debug "insed"
        logger.debug row["district_id"]
        if row["district_id"] == district_id
          return row["district_name"]
        end
      end
    end
    return "-"
  end  

  def get_resource_targets(resource_obj,from_month,to_month)
    actual_target = 0
    resource_targets = resource_obj.resource_targets.by_month_range(from_month,to_month)
    
    resource_targets.each do |target|
      if target.target_type == "by_amount"
        actual_target += target.target_amount
      else
        actual_target += target.user_target_products.sum(:target_quantity)
      end
    end
    return actual_target
  end
  def get_achieved_target_for_resource(resource_obj,from_month,to_month)
    achieved_target = 0
    resource_sale = resource_obj.user_sales.by_recorded_at_month_range(from_month,to_month)
    if resource_sale.present?
      achieved_target += resource_sale.sum(:quantity)
    end
    return achieved_target
  end
  def current_year_and_previous_year_product_dispatch(product_id='',store_id='',resource_ids='')
    current_year = Time.now.year
    if resource_ids == ''
      if product_id == '' 
        current_year_dispatch = OrderDetail.by_store(store_id).valid_item.by_recorded_at_year(current_year).sum(:quantity)
        previous_year_dispatch = OrderDetail.by_store(store_id).valid_item.by_recorded_at_year(current_year-1).sum(:quantity)
      else
        current_year_dispatch = OrderDetail.by_store(store_id).by_product(product_id).valid_item.by_recorded_at_year(current_year).sum(:quantity)
        previous_year_dispatch = OrderDetail.by_store(store_id).by_product(product_id).valid_item.by_recorded_at_year(current_year-1).sum(:quantity)
      end
    else
      order_ids = Order.set_resources(resource_ids).pluck(:id)
      order_details = OrderDetail.by_order_ids(order_ids).by_product(product_id).valid_item
      current_year_dispatch = order_details.by_recorded_at_year(current_year).sum(:quantity)
      previous_year_dispatch = order_details.by_recorded_at_year(current_year-1).sum(:quantity)
    end
    current_year_dispatch = 0 if !current_year_dispatch.present?
    previous_year_dispatch = 0 if !previous_year_dispatch.present?
    return [current_year_dispatch,previous_year_dispatch]
  end
end
