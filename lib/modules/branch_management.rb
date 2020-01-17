module BranchManagement
  
########################################
## Get the unit of the parent unittypes
########################################
  def self.branchs_get_parent_units(id)
    @type_prio = Unittype.where(:id => id).select('unit_type_priority')
    @type_prio_id = @type_prio[0].unit_type_priority
    @type_prio_id_arr = [@type_prio_id, (@type_prio_id-1)]
    #@Req_type_prio = Unittype.find(:all, :select => 'id', :conditions => ["unit_type_priority =?", @type_prio_id-1])
    @Req_type_prio = Unittype.where("unit_type_priority in(?)", @type_prio_id_arr).select('id, unit_type_name')
    ids = Array.new 
    @Req_type_prio.each do |r|
     ids.push(r.id)
    end
    @type_info = Unit.where(:unittype_id => ids)
    #@type_info = Unit.find(:all, :conditions => ['unittype_id in(?)', ids])
    return @type_info
  end
############################################ 

########################################
## Get current unit details
########################################
  # def self.get_unit_details(id)
  #   @type_prio = Unit.find(id)
  #   return @type_prio
  # end
  
  #Getting current unit credit limit
  # def self.get_unit_current_credit_limit(unit_id)
  #   _unit_details = Unit.find(unit_id)
  #   _unit_stores = Store.unit_stores(unit_id).physical.primary.first
  #   _total_bill = 0.0
  #   _unit_stores.each do |us|
  #     _store_id = us.id
  #     _purchase_bill = Stock.sum(:price, :conditions=>["store_id =? and activity_id=?",_store_id,1])
  #     _trans_credit_bill = Stock.sum(:price, :conditions=>["to_store =? and activity_id=? and status=?",_store_id,2, "5.1"])
  #     _total_bill = _total_bill + _purchase_bill + _trans_credit_bill
  #   end
  #   _current_credit = ((_unit_details.credit_limit).to_f) - _total_bill
  #   return _current_credit
  # end    
########################################
## Get all leaf unit details
######################################## 
  def self.get_leaf_units()
    _max_unit_type_priority = Unittype.maximum("unit_type_priority")
    _max_unit_type_id = Unittype.where(:unit_type_priority => _max_unit_type_priority).first.id
    _leaf_units = Unit.where(:unittype_id => _max_unit_type_id)
  end
########################################
  
########################################
## get info window in gmap for units
########################################  
  def self.get_infowindow(unitall, menu_product, source)
    hash = Gmaps4rails.build_markers(unitall) do |unit, marker|
      total_sell = OrderManagement::get_total_sell_by_menu_product(menu_product, unit.id, source)
      
      # resturant_image = OwnerRegistration.find(:first, :select => 'resturant_image')
      # <span class='col-sm-3'><img class ='img-thumbnail ll' src='/uploads/resturants/#{resturant_image.resturant_image}' /></span>

      unit_infowindow = "<div class ='row' style='width:400px;'>
            <span class='col-sm-3'><img class ='img-thumbnail ll' src='#{unit.unit_image.url(:thumb)}' /></span>
              <span class='col-sm-9'>
                <b>#{unit.unit_name}</b>(
                <small>#{unit.unittype.unit_type_name}</small>)<br>
                <i class='fa fa-home'></i> #{unit.locality}<br>
                #{unit.city} - #{unit.pincode}, #{unit.state}<br>
                <i class='fa fa-tty'></i> #{unit.phone}<br>
                <i class='fa fa-rupee'></i> #{total_sell[1]} (#{total_sell[0]} pc)<br>
                <i class='fa fa-wheelchair'></i> #{unit.phone}<br>
              </span></div>"
      #marker.lat unit.latitude
      #marker.lng unit.longitude
      #marker.infowindow unit_infowindow
      marker.title   "#{unit.locality}"
      #marker.sidebar "i'm the sidebar"
      marker.json({ :lat => unit.latitude, :lng => unit.longitude, :infowindow => unit_infowindow, 
                    :marker => "<div class ='markers_content' style='font-weight:bold; color:red; background: #fff;'>
            <span class='col-sm-3'><i class ='fa fa-home fa-lg'></i></span>
              <span class='col-sm-9'>
                <i class='fa fa-rupee'></i> #{total_sell[:total_sell]} (#{total_sell[:total_sell_quantity]} #{total_sell[:product_basic_unit]})<br>
                <i class='fa fa-wheelchair'></i> #{unit.phone}<br>
              </span></div>"})
      # marker.picture({
                  # :url => "https://addons.cdn.mozilla.net/img/uploads/addon_icons/13/13028-64.png",
                  # :width   => 60,
                  # :height  => 60
          # })
      
    end
  end
  
  ##################################################################
  ### Get the subchilds detail with stock detail of a given product
  ##################################################################
  def self.get_unit_childs(product_id,_root_unit_id)
    _child_units = Unit.where(:unit_parent => _root_unit_id)
    main_arr = Array.new
    _child_units.each do |cu|
      _unit_stock =  StoreManagement::get_stock_details(product_id,cu.id)
      _root_childs = get_unit_childs(product_id,cu.id)
      _tree_hash = {}
        _attr_hash = {}
        _attr_hash[:id] = cu.id 
      _tree_hash[:unit_id] = cu.id 
      _tree_hash[:unit_name] = cu.unit_name
      _tree_hash[:unit_stock] = _unit_stock
      _tree_hash[:children] = _root_childs 
      main_arr.push(_tree_hash)     
    end
    return main_arr
  end
  ###################################################################
############################################ 
end
