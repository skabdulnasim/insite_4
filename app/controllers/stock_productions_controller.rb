class StockProductionsController < ApplicationController
  load_and_authorize_resource
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details
  before_filter :get_current_user, only: [:new, :create]
  before_filter :set_store, only: [:new, :create, :show, :update]

  # GET /stock_productions/1
  # GET /stock_productions/1.json
  def show
    puts params[:id]
    @site_title = AppConfiguration.get_config_value('site_title')
    @stock_production = StockProduction.find(params[:id])
    puts "stock production meta details =#{@stock_production.stock_production_metas[0].stock_production_meta_processes.inspect}"
    # @stock_production.each do |production|
    #   puts "stock production details"
    #   production.stock_production_metas.stock_production_meta_processes.id.inspect
    # end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stock_production }
    end
  end

  # GET /stock_productions/new
  # GET /stock_productions/new.json
  # FUnction Used ********************
  def new
    # @menu_products = MenuManagement::get_activated_menu_products(@current_user.unit_id)
    _pro_arr = Array.new
    # _menu_products = MenuManagement::get_activated_menu_products(@current_user.unit_id)
    _menu_products = MenuManagement::get_production_section_activated_menu_products(@current_user.unit_id)
    _menu_products.each do |mp|
      _pro_arr.push(mp.product_id)
    end
    @menu_products = Product.set_id_in(_pro_arr).order("name asc")
    @menu_products = @menu_products.filter_by_string(params[:product_filter]) if params[:product_filter].present?
    @menu_products = @menu_products.set_category(params[:catrgory]) if params[:catrgory].present?
    @menu_products = @menu_products.filter_by_string(params[:filter]) if params[:filter].present?

    smart_listing_create :menu_products, @menu_products, partial: "stock_productions/menu_products_smartlist", default_sort: {id: "desc"}
    
    @ingredient_arrss = {}
    @menu_products.each do |mp|
      sub_products = ProductComposition::get_sub_products(mp.id)
      sub_products.each do |mk|
        _sub_product_details = ProductComposition::get_product_details_by_id(mk['raw_product_id'])
        _sub_pro_id = _sub_product_details[:id]
        _sub_pro_stock = get_product_current_stock(@store.id, _sub_pro_id)

        # Filling the ingredients array
        _raw_arr = {}
        _raw_arr[:raw_product_id]   = _sub_pro_id
        _raw_arr[:raw_product_name] = _sub_product_details[:name]
        # _raw_arr[:raw_product_unit] = _sub_product_details[:basic_unit]
        _raw_arr[:raw_product_unit] = _sub_product_details.basic_unit
        _raw_arr[:raw_product_stock] = _sub_pro_stock
        if !@ingredient_arrss.has_key?(_sub_pro_id)  
          @ingredient_arrss[_sub_pro_id] = _raw_arr
        end
        @ingredient_arr_full = @ingredient_arrss
      end
    end
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end      
  rescue Exception => e
    Rscratch::Exception.log e,request
    redirect_to kitchen_store_store_path(@store), alert: e.message 
  end

  # POST /stock_productions
  # POST /stock_productions.json
  # FUnction Used *******************
  def create
    #puts params[:checked_raw][0]
    begin
      params[:checked_raw] = params[:checked_raw][0].split(',')
      if params[:checked_raw].length == 0
        redirect_to new_store_stock_production_path(@store), alert: 'No products selected for production.' and return
      end
      ActiveRecord::Base.transaction do # Protective transaction block
        _new_production = StockProduction.new(params[:stock_production]) #Step 3 : Creating production
        _new_production.isStockAdded = 0
        @store.stock_productions << _new_production
        @product_raws = {}
        params[:checked_raw].each do |cp|
          raw_quantity_hash={}
          _mp_sub_pros = ProductComposition::get_sub_products(cp)
          _mp_sub_pros.each do |sub_p|
            _raw_product_quantity = params["menu_product_#{cp}_raw_#{sub_p.raw_product_id}"]
            raw_quantity_hash["#{sub_p.raw_product_id}"]= params["menu_product_#{cp}_raw_#{sub_p.raw_product_id}"]
            puts raw_quantity_hash
          end
          _price,_ingr = consume_menu_product_raws(cp,@store.id,params["quantity_#{cp}"],@product_raws,raw_quantity_hash)
          _meta_entry = StockProductionMeta.new(:product_id=>cp,:ingredients=>_ingr, :production_quantity=> params["quantity_#{cp}"], :price=> _price, :store_id=>@store.id)
          _new_production.stock_production_metas << _meta_entry
          _product = Product.find(cp)
          if _product.package_component.present?
            package_components = _product.name.split('-')
            package_unit_id = package_components[1]
            package_unit_product = PackageUnitProduct.by_package_unit(package_unit_id).by_product(cp)
            package_unit_product.first.update_column(:production_status, '1') if package_unit_product.present?
          end
        end        
        @product_raws.each do |sp|
          _raw_stock = StockUpdate.current_stock(@store.id,sp[1][:product_id])
          raise "Error! product do not have sufficient stock for production" if _raw_stock < sp[1][:production_qty]
          Stock.save_stock(sp[1][:product_id],@store.id,0,0,_new_production.id,'stock_production',0,sp[1][:production_qty],nil,nil,nil)
        end        
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to kitchen_store_store_path(@store), alert: e.message
    else
      redirect_to kitchen_store_store_path(@store), notice: 'Production process was successfully initiated.'
    end
  end

  # PUT /stock_productions/1
  # PUT /stock_productions/1.json
  # FUnction Used *******************
  # def update
  #   @stock_production = StockProduction.find(params[:id])
  #   _status = @stock_production.status
  #   puts _status
  #   respond_to do |format|
  #     if @stock_production.update_attributes(params[:stock_production])
  #       # if @stock_production.isStockAdded == 0
  #       if _status == "2"
  #         # credit_production_stock(@stock_production.id)
  #         raise 'No Product checkbox selected.' unless params[:selected_products].present?
  #         params[:selected_products].each do |p_id|
  #           # Stock.save_stock(spm.product_id,_stock_production.store_id,spm.price,spm.production_quantity,_stock_production.id,'stock_production',spm.production_quantity,0,nil,nil,nil) 
  #           sp_meta = StockProductionMeta.find_by_stock_production_id_and_product_id(@stock_production.id,p_id)
  #           sp_meta_price = sp_meta.price
  #           Stock.save_stock(p_id,@stock_production.store_id,"#{sp_meta_price}",params["production_quantity_#{p_id}"],@stock_production.id,"stock_production",params["production_quantity_#{p_id}"],0,params["expiry_date_#{p_id}"],params["sku_#{p_id}"],params["mfg_date_#{p_id}"],params["model_number_#{p_id}"],params["size_#{p_id}"],params["color_#{p_id}"],nil)
  #         end
  #         @stock_production.update_attributes(:isStockAdded => 1)
  #       end
  #       if @stock_production.isStockAdded == 1
  #         format.html { redirect_to store_path(@store), notice: 'Production was successfully completed and added to stock.' }
  #       else
  #         format.html { redirect_to store_stock_production_path(@store,@stock_production), notice: 'Production was successfully completed.' }
  #       end
  #     else
  #       format.html { render action: "edit" }
  #     end
  #   end
  # end

  # begin
  #   raise 'No Product checkbox selected.' unless params[:products].present?
  #   ActiveRecord::Base.transaction do # Protective transaction block
  #     params[:products].each do |pro|
  #       _menu_product = current_user.unit.unit_products.create(:product_id=>pro,:input_tax_group_id=>params[:tax_group_id])
  #     end
  #   end
  #   redirect_to unit_products_products_path, notice: "Products successfully added to your branch"
  # rescue Exception => e
  #   Rscratch::Exception.log e,request
  #   redirect_to unit_products_products_path, alert: e.message.to_s
  # end

  def update
    @stock_production = StockProduction.find(params[:id])
    _status = @stock_production.status
    _stock_production_update = @stock_production.update_attributes(params[:stock_production])
    begin
      if _stock_production_update
        if _status == "2" && @stock_production.isStockAdded != 1
          # raise 'No Product checkbox selected.' unless params[:selected_products].present?
          params[:selected_products].each do |p_id|
            # Stock.save_stock(spm.product_id,_stock_production.store_id,spm.price,spm.production_quantity,_stock_production.id,'stock_production',spm.production_quantity,0,nil,nil,nil) 
            sp_meta = StockProductionMeta.find_by_stock_production_id_and_product_id(@stock_production.id,p_id)
            sp_meta_price = sp_meta.price
            save_stock = Stock.save_stock(p_id,@stock_production.store_id,"#{sp_meta_price}",params["production_quantity_#{p_id}"],@stock_production.id,"stock_production",params["production_quantity_#{p_id}"],0,params["expiry_date_#{p_id}"],params["sku_#{p_id}"],params["mfg_date_#{p_id}"],params["model_number_#{p_id}"],params["size_#{p_id}"],params["color_#{p_id}"],nil,nil,nil,params["batch_no_#{p_id}"],nil)
            
            if save_stock
              if AppConfiguration.get_config_value('uniqe_sku_for_stock') == 'enabled'
                sku = params["sku_#{p_id}"].present? ? params["sku_#{p_id}"] : format('%08d', save_stock.id)
              else    
                sku = params["sku_#{p_id}"].present? ? params["sku_#{p_id}"] : format('%08d', save_stock[:product_id]) 
              end
              save_stock.update_column(:sku, sku)
              if save_stock.product.package_component.present?
                _product_name = save_stock.product.name
                package_components = _product_name.split('-')
                package_id = package_components[0]
                package_unit_id = package_components[1]
                package_component_id = package_components[2]
                package_unit_product = PackageUnitProduct.by_package_unit(package_unit_id).by_product(save_stock.product_id)
                # package_unit_product.first.update_attributes(:sku=>sku, :production_status => '2') if package_unit_product.present?
                package_unit_product.first.update_column(:sku, sku) if package_unit_product.present?
                package_unit_product.first.update_column(:production_status, '2') if package_unit_product.present?
                
                package = Package.find(package_id)
                package_unit_ids = []
                package.package_units.map { |e| package_unit_ids.push e.id }
                package_unit_products = PackageUnitProduct.set_package_unit_in(package_unit_ids) if package_unit_ids.present?

                completed_package_unit_products = package_unit_products.where(:production_status => '2')

                if package_unit_products.count >= completed_package_unit_products.count
                  if package_unit_products.count == completed_package_unit_products.count
                    package.update_column(:production_status, '2')
                  else
                    package.update_column(:production_status, '1')
                  end
                else
                  package.update_column(:production_status, '0')
                end
              end
              # StockPrice.add_stock_price(stock.id, row["Landing Price per unit"], row["MRP"], stock[:product_id], total_price_without_tax.to_f, total_tax, stock_additional_cost, total_price_with_tax, "",stock_discount,nil,row["Sell price without tax"])
              k = StockPrice.add_stock_price(save_stock.id, nil, params["mrp_#{p_id}"], save_stock[:product_id], nil, nil, nil, 100, "",nil,nil,nil)
            end
          end
          @stock_production.update_attributes(:isStockAdded => 1)
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
    end
    respond_to do |format|
      if _stock_production_update
        if @stock_production.isStockAdded == 1
          format.html { redirect_to store_stock_production_path(@store,@stock_production), notice: 'Production was successfully completed and added to stock.' }
        else
          format.html { redirect_to store_stock_production_path(@store,@stock_production), notice: 'Production was successfully completed.' }
        end
      else
        format.html { render action: "edit" }
      end
    end
  end

  # def update
  #   @stock_production = StockProduction.find(params[:id])
  #   puts params
  #   respond_to do |format|
  #     if @stock_production.update_attributes(params[:stock_production])
  #       credit_production_stock(@stock_production.id)
  #       format.html { redirect_to store_path(@store), notice: 'Production was successfully completed and added to stock.' }
  #     else
  #       format.html { render action: "edit" }
  #     end
  #   end
  # end

  def stock_production_meta_process_update
    @s_p_meta_processes = StockProductionMetaProcess.find_by_stock_production_meta_id_and_production_process_id(params[:stock_production_meta_id],params[:process_id])
    current_time = Time.now.utc
    process_duration_in_sec = @s_p_meta_processes.production_process_duration * 60
    if params[:process_status]=="start"
      process_expected_end_time = current_time + process_duration_in_sec
      @s_p_meta_processes.update_attributes(:status => params[:process_status], :actual_start_time=>current_time, :expected_end_time => process_expected_end_time, :process_width=>params[:process_width])
    elsif params[:process_status]=="stop"
      @s_p_meta_processes.update_attributes(:status => params[:process_status], :process_width=>params[:process_width])
    elsif params[:process_status]=="done"
      @s_p_meta_processes.update_attributes(:status => params[:process_status], :actual_end_time=>current_time)
    end

    respond_to do |format|
      format.json { render json: @s_p_meta_processes }
    end
  end

  def stock_production_meta_process_width_update
    @s_p_meta_processes = StockProductionMetaProcess.find_by_stock_production_meta_id_and_production_process_id(params[:stock_production_meta_id],params[:process_id])
    
    if params[:process_status]=="start"
      @s_p_meta_processes.update_attributes(:process_width=>params[:process_width])
    end

    respond_to do |format|
      format.json { render json: @s_p_meta_processes }
    end
  end

  def check_process_dependency
    @process_composition = ProcessComposition.find(params[:process_composition_id])
    @process_dependencies = @process_composition.depends_on_processes
    incomplete_processes = Array.new
    target_product_id = params[:target_product_id]
    if @process_dependencies.present?
      @process_dependencies.each do |dependency_process|
        @process_status = StockProductionMetaProcess.find_by_stock_production_meta_id_and_target_product_id_and_production_process_id(params[:stock_production_meta_id],params[:target_product_id],dependency_process.process_id)
        if @process_status.status != "done"
          _arr = {}
          _arr = @process_status.production_process.name
          incomplete_processes.push(_arr)
        end
      end
    end 
    respond_to do |format|
      format.json { render json: incomplete_processes }
    end
  end

  def get_production_status
    @stock_production_meta_processes = StockProductionMetaProcess.where("stock_production_meta_id=?", params[:meta_id])
    @production= StockProduction.find_by_id(params[:production_id])
    puts @production.inspect
    puts @stock_production_meta_processes.inspect
    _status_array=[]
    @stock_production_meta_processes.each do |meta_process|
      _status_array.push(meta_process.status)
    end
    puts _status_array
    if ( _status_array.count('initialize') ==  _status_array.length)
      _status = "initialize"
      _status_code= "1" 
    else
      if ( _status_array.count('done') ==  _status_array.length)
        _status = "Production finished"
        _status_code= "2"
      else
        if  _status_array.include? "start"
          _status = "Production Started"
          _status_code= "3"
         else 
          _status = "Production Halted"
          _status_code= "4"
         end
      end
    end
    @production.update_attributes(status: _status_code)
    puts "production id = #{params[:production_id]} and status = #{_status}"
    respond_to do |format|
      format.json{render json:{status:_status, status_code:_status_code}}
    end
  end
  
  private 
  
  def set_module_details
    @module_id = "inventory"
    @module_title = "Inventory"
  end

  def set_store
      @store = Store.find(params[:store_id])
  end

  def consume_menu_product_raws(_mpro_id,_store_id,_mp_qty,_product_arry,raw_quantity_hash)
    #Building the raw product array
    _production_raws = Array.new
    _raw_price = 0
    _mp_sub_pros = ProductComposition::get_sub_products(_mpro_id)
    _mp_sub_pros.each do |mk|
      _raw_pro_id = mk['raw_product_id']
      _pro_unit_multiplier = (ProductUnit.find(mk['raw_product_unit'])).multiplier

      # to estimate stock deduction with unit quantity you can uncomment the below  line 
      # _total_raw_qty = (_pro_unit_multiplier.to_f)*(mk['raw_product_quantity'].to_f)*(_mp_qty.to_f)
      
      #to estimate stock deduction for variable quantity of raw product
      _total_raw_qty = (_pro_unit_multiplier.to_f)*raw_quantity_hash["#{_raw_pro_id}"].to_f
      if _product_arry && _product_arry.has_key?(_raw_pro_id)  
         _product_arry[_raw_pro_id][:production_qty] = ((_product_arry[_raw_pro_id][:production_qty]).to_f + _total_raw_qty)   
      else
        _raw_arr = {:product_id=>_raw_pro_id,:production_qty=>_total_raw_qty}
        _product_arry[_raw_pro_id] = _raw_arr              
      end  
      #Consuming the stock for this raw item
      _price = Stock.consumption_with_automated_debit(_store_id,_raw_pro_id,raw_quantity_hash["#{_raw_pro_id}"].to_f * (_pro_unit_multiplier.to_f),'Production Center Consumption')
      _raw_price = _raw_price + _price
      # _raw_arr = {:raw_product_id => _raw_pro_id, :raw_product_quantity=> _total_raw_qty}
      _raw_arr = {:raw_product_id => _raw_pro_id, :raw_product_quantity=>raw_quantity_hash["#{_raw_pro_id}"].to_f * (_pro_unit_multiplier.to_f) }
      _production_raws.push(_raw_arr)
    end
    _production_raws_json = JSON.generate(_production_raws)
    return [_raw_price,_production_raws_json]
  end

  def credit_production_stock(id)
    _stock_production = StockProduction.find(id)
    _stock_production.stock_production_metas.each do |spm|
      Stock.save_stock(spm.product_id,_stock_production.store_id,spm.price,spm.production_quantity,_stock_production.id,'stock_production',spm.production_quantity,0,nil,nil,nil)
    end
  end
end