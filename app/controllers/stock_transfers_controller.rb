class StockTransfersController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  layout "material"

  before_filter :set_module_details
  before_filter :set_store, only: [:transfer_options, :new, :show, :update]
  before_filter :get_current_user, only: [:transfer_options, :create, :update_status, :update, :new]

  # GET /stock_transfers/1
  # GET /stock_transfers/1.json
  def show
    @stock_transfer = StockTransfer.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stock_transfer.to_json(:include => [{:stocks => {:include => :product}}, :from_store, :to_store] ) }
    end
  end

  # GET /stock_transfers/new
  # GET /stock_transfers/new.json
  def new
    @categories = Category.all
    @store = Store.find(params[:store_id])
    @stock_transfer = StockTransfer.new
    @shipping_module = AppConfiguration.get_config_value('shipping_module')
    @vehicles = Vehicle.unit_vehicles(current_user.unit_id)
    if @store.store_type == "return_store"
      # product_scope = @store.return_items
      # product_scope = product_scope
      if params["sku_filter"].present?
        product_scope = Stock.set_store(@store.id).available.by_sku(params[:sku_filter])
      else
        product_scope = Stock.set_store(@store.id).available
      end
    else  
      product_scope = @store.products.present? ? @store.products : Product.get_all
    end  
    #product_scope = product_scope.joins(:stocks).where("stocks.store_id = (?) AND stocks.available_stock > (?)", "#{params[:store_id]}", 0)
    product_scope = product_scope.filter_by_product_type(params[:product_type]) if params[:product_type].present?
    product_scope = product_scope.by_category_id(params[:product_category]) if params[:product_category].present?
    product_scope = product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    product_scope = product_scope.filter_by_sku(product_scope,params[:sku_filter],params[:store_id]) if params[:sku_filter].present?
    product_scope = product_scope.filter_by_product_id(params[:product_id_filter]) if params[:product_id_filter].present?
    
    if params[:business_type] == 'by_catalog' && @store.store_type == "return_store"
      smart_listing_create :products, product_scope, partial: "products/return_store_product_stock_transfer_smartlist", default_sort: {id: "desc"}
    elsif params[:business_type] == 'by_catalog'
      smart_listing_create :products, product_scope.by_business_type(params[:business_type]), partial: "products/product_stock_transfer_smartlist", default_sort: {id: "desc"}
    elsif @store.store_type == "kitchen_store"
      smart_listing_create :products, product_scope, partial: "products/product_stock_transfer_smartlist", default_sort: {id: "desc"}      
    end
    smart_listing_create :products, product_scope.by_business_type(params[:business_type]), partial: "products/mrp_product_stock_transfer_smartlist", default_sort: {id: "desc"} if params[:business_type] == 'by_mrp'
    smart_listing_create :products, product_scope.by_business_type(params[:business_type]), partial: "products/mrp_product_stock_transfer_smartlist", default_sort: {id: "desc"} if params[:business_type] == 'by_weight'
    smart_listing_create :products, product_scope.by_business_type(params[:business_type]), partial: "products/mrp_product_stock_transfer_smartlist", default_sort: {id: "desc"} if params[:business_type] == 'by_bulk_weight'

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  # POST /stock_transfers
  # POST /stock_transfers.json

  def create
    if params[:business_type] == 'by_catalog'
      if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
        @stock_transfer = StockTransfer.new(params[:stock_transfer].except(:product_tokens))
        puts @stock_transfer.errors.full_messages
        @stock_transfer.save
        puts @stock_transfer.errors.full_messages
        @store = Store.find(@stock_transfer[:primary_store_id])
        if AppConfiguration.get_config_value('stock_identity') == 'enabled'
          params[:checked_stock_id].each do |stock_id|
            _stock_transfer_metum = StockTransferMetum.new
            _stock_transfer_metum[:stock_transfer_id] = @stock_transfer.id
            _stock_transfer_metum[:product_id] = params["product_id#{stock_id}"]
            _stock_transfer_metum[:quantity_transfered] = params["quentity#{stock_id}"]
            _stock_transfer_metum[:quantity_received] = params["quentity#{stock_id}"]
            _stock_transfer_metum[:stock_id] = stock_id
            _stock_transfer_metum[:expery_date] = params["expiry_date#{stock_id}"]
            _stock_transfer_metum[:sale_price_without_tax] = params["sale_price_without_tax#{stock_id}"]
            _stock_transfer_metum[:mrp] = params["mrp#{stock_id}"]
            _stock_transfer_metum[:size_name] = params["size#{stock_id}"]
            _stock_transfer_metum[:model_number] = params["model_number#{stock_id}"]
            _stock_transfer_metum[:color_name] = params["color_name#{stock_id}"]
            _stock_transfer_metum[:procurment_price] = params["procurment_price#{stock_id}"]
            _stock_transfer_metum[:color_id] = params["color_id#{stock_id}"]
            _stock_transfer_metum[:size_id] = params["size_id#{stock_id}"]
            _stock_transfer_metum[:batch_no] = params["batch_no#{stock_id}"]
            _stock_transfer_metum[:picked_quantity] = 0
            _stock_transfer_metum[:product_transaction_unit_id] = params["transfered_in#{stock_id}"]
            _stock_transfer_metum[:sku] = params["sku#{stock_id}"]
            _stock_transfer_metum[:stock_identity] = params["stock_identity#{stock_id}"]
            _stock_transfer_metum.save
          end
        else  
          params[:checked_sku].each do |sku|
            _stock_transfer_metum = StockTransferMetum.new
            _stock_transfer_metum[:stock_transfer_id] = @stock_transfer.id
            _stock_transfer_metum[:product_id] = params["product_id#{sku}"]
            _stock_transfer_metum[:quantity_transfered] = params["quentity#{sku}"]
            _stock_transfer_metum[:quantity_received] = params["quentity#{sku}"]
            _stock_transfer_metum[:sku] = sku
            _stock_transfer_metum[:expery_date] = params["expiry_date#{sku}"]
            _stock_transfer_metum[:sale_price_without_tax] = params["sale_price_without_tax#{sku}"]
            _stock_transfer_metum[:mrp] = params["mrp#{sku}"]
            _stock_transfer_metum[:size_name] = params["size#{sku}"]
            _stock_transfer_metum[:model_number] = params["model_number#{sku}"]
            _stock_transfer_metum[:color_name] = params["color_name#{sku}"]
            _stock_transfer_metum[:procurment_price] = params["procurment_price#{sku}"]
            _stock_transfer_metum[:color_id] = params["color_id#{sku}"]
            _stock_transfer_metum[:size_id] = params["size_id#{sku}"]
            _stock_transfer_metum[:batch_no] = params["batch_no#{sku}"]
            _stock_transfer_metum[:picked_quantity] = 0 #for warehouse managements the default value will always be 0
            _stock_transfer_metum[:product_transaction_unit_id] = params["transfered_in#{sku}"]
            _stock_transfer_metum.save
          end
        end  
        respond_to do |format|
          if @stock_transfer.stock_transfer_meta
            format.html { redirect_to store_stock_transfer_steps_path(@store,@stock_transfer), notice: 'Stock transfer initiated' }
            format.js
          else
            format.html { render action: "new"}
            format.js
          end
        end 
      else  
        @stock_transfer = StockTransfer.new(params[:stock_transfer])
        @store = Store.find(@stock_transfer[:primary_store_id])
        respond_to do |format|
          if @stock_transfer.save
            @stock_transfer.stock_transfer_meta.each do |stock_meta|
              stock_meta.update_attributes(:quantity_transfered=>params["quentity#{stock_meta.product_id}"]) if params["quentity#{stock_meta.product_id}"].present?
              stock_meta.update_attributes(:product_transaction_unit_id=>params["transfered_in#{stock_meta.product_id}"]) if params["transfered_in#{stock_meta.product_id}"].present?
            end  
            format.html { redirect_to store_stock_transfer_steps_path(@store,@stock_transfer), notice: 'Stock transfer initiated' }
            format.js
          else
            format.html { render action: "new"}
            format.js
          end
        end
      end 
    else
      @stock_transfer = StockTransfer.new(params[:stock_transfer].except(:product_tokens))
      @stock_transfer.save
      @store = Store.find(@stock_transfer[:primary_store_id])
      params[:checked_sku].each do |sku|
        _stock_transfer_metum = StockTransferMetum.new
        _stock_transfer_metum[:stock_transfer_id] = @stock_transfer.id
        _stock_transfer_metum[:product_id] = params["product_id#{sku}"]
        _stock_transfer_metum[:quantity_transfered] = params["quentity#{sku}"]
        _stock_transfer_metum[:quantity_received] = params["quentity#{sku}"]
        _stock_transfer_metum[:sku] = sku
        _stock_transfer_metum.save
      end
      respond_to do |format|
        if @stock_transfer.stock_transfer_meta
          format.html { redirect_to store_stock_transfer_steps_path(@store,@stock_transfer), notice: 'Stock transfer initiated' }
          format.js
        else
          format.html { render action: "new"}
          format.js
        end
      end   
    end  
  end

  # PUT /stock_transfers/1
  # PUT /stock_transfers/1.json
  def update
    begin
      @stock_transfer = StockTransfer.find(params[:id])
      ActiveRecord::Base.transaction do # Protective transaction block
        if @stock_transfer.update_attributes(params[:stock_transfer])
          if @stock_transfer.store_requisition_log_id.present?
            @stock_transfer.stock_transfer_meta.each do |stock_meta|
              update_requisition_log(stock_meta.product_id,@stock_transfer.store_requisition_log_id,stock_meta.quantity_transfered,stock_meta.color_id,stock_meta.size_id)
            end
          end
          if @stock_transfer.status == '50'
            _stocks = Stock.set_transaction(params[:id]).set_transaction_type("StockTransfer")
            _stocks.each do |stock|
              Stock.save_stock(stock.product_id,stock.store_id,stock.price,stock.stock_debit,stock.stock_transaction_id,'stock_transfer',stock.stock_debit,stock.stock_credit,stock.expiry_date,stock.sku,stock.mfg_date,stock.model_number,stock.size_name,stock.color_name,stock.sell_price_with_tax,stock.color_id,stock.size_id,stock.batch_no)
            end
          end     
          redirect_to store_stock_transfer_path(@store,@stock_transfer), notice: 'Stock transfer was successfully updated'
        else
          @validation_errors = error_messages_for(@stock_transfer)
          raise @validation_errors if @validation_errors.present?
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to :back, alert: e.message
    end
  end

  # Use Log : Transfer status updated by delivery van
  def update_status
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        @stock_transfer = StockTransfer.find(params[:id])
        # _status_log = StockTransfer.generate_status_json(@stock_transfer.id,params[:status],params[:status_desc],@current_user.id)
        @stock_transfer.update_attribute(:status, params[:status])
        # @stock_transfer.update_attribute(:status_log, _status_log)
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to "/vehicles/#{@stock_transfer.vehicle_id}", alert: e.message
    else
      redirect_to "/vehicles/#{@stock_transfer.vehicle_id}", notice: 'Shipment status was successfully updated.'
    end
  end

  def generate_invoice
    @stock_transfer = StockTransfer.find(params[:stock_transfer_id])
    @account = request.subdomain
    @dice = "/uploads/product.png"
    respond_to do |format|
      format.html # show.html.erb
      format.pdf { render :layout => false } # Add this line
    end
  end

  def custom_create_for_requistion
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        @stock_transfer = StockTransfer.new
        @store = Store.find(params[:primary_store_id])
        raise 'No products selected for new purchase order.' unless !params[:checked_raw].nil?
        @stock_transfer[:transfer_type]=params[:transfer_type]
        @stock_transfer[:secondary_store_id]=params[:secondary_store_id]
        @stock_transfer[:primary_store_id]=params[:primary_store_id]
        @stock_transfer[:store_requisition_log_id]=params[:store_requisition_log_id]
        @stock_transfer[:status] = "0"
        @stock_transfer[:activity_id] = 2
        @stock_transfer.save
        params[:checked_raw].each do |c|
          if params[:business_type] == 'by_catalog'
            _stock_transfer_metum = StockTransferMetum.new
            if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
              _product_counter = params["quantity#{c}"]
              _product_color_size = c.split('_')
              _color_id = _product_color_size[1] != '0' ? _product_color_size[1] : ''
              _size_id = _product_color_size[2] != '0' ? _product_color_size[2] : ''
              _transfer_options = Stock.product_debit_options(params[:primary_store_id], _product_color_size[0],'',_size_id,_color_id)
              if _transfer_options.present?
                _transfer_options.each do |at|
                  if _product_counter.to_f >= at.available_stock.to_f
                    _stock_transfer_metum = StockTransferMetum.new
                    _stock_transfer_metum[:stock_transfer_id] = @stock_transfer.id
                    _stock_transfer_metum[:product_id] = _product_color_size[0]
                    _stock_transfer_metum[:quantity_transfered] = at.available_stock
                    _stock_transfer_metum[:quantity_received] = at.available_stock
                    _stock_transfer_metum[:sku] = at.sku
                    _stock_transfer_metum[:expery_date] = at.expiry_date
                    _stock_transfer_metum[:sale_price_without_tax] = at.sell_price_with_tax
                    _stock_transfer_metum[:mrp] = at.stock_price.present? ? at.stock_price.mrp : 0
                    _stock_transfer_metum[:size_name] = at.size_name
                    _stock_transfer_metum[:model_number] = at.model_number
                    _stock_transfer_metum[:color_name] = at.color_name
                    _stock_transfer_metum[:procurment_price] = at.stock_price.present? ? at.stock_price.landing_price : 0
                    _stock_transfer_metum[:color_id] = at.color_id
                    _stock_transfer_metum[:size_id] = at.size_id
                    _stock_transfer_metum[:batch_no] = at.batch_no
                    _stock_transfer_metum.save
                    _product_counter = _product_counter.to_f - (at.available_stock).to_f
                  elsif _product_counter.to_f > 0
                    _stock_transfer_metum = StockTransferMetum.new
                    _stock_transfer_metum[:stock_transfer_id] = @stock_transfer.id
                    _stock_transfer_metum[:product_id] = _product_color_size[0]
                    _stock_transfer_metum[:quantity_transfered] = _product_counter
                    _stock_transfer_metum[:quantity_received] = _product_counter
                    _stock_transfer_metum[:sku] = at.sku
                    _stock_transfer_metum[:expery_date] = at.expiry_date
                    _stock_transfer_metum[:sale_price_without_tax] = at.sell_price_with_tax
                    _stock_transfer_metum[:mrp] = at.stock_price.present? ? at.stock_price.mrp : 0
                    _stock_transfer_metum[:size_name] = at.size_name
                    _stock_transfer_metum[:model_number] = at.model_number
                    _stock_transfer_metum[:color_name] = at.color_name
                    _stock_transfer_metum[:procurment_price] = at.stock_price.present? ? at.stock_price.landing_price : 0
                    _stock_transfer_metum[:color_id] = at.color_id
                    _stock_transfer_metum[:size_id] = at.size_id
                    _stock_transfer_metum[:batch_no] = at.batch_no
                    _stock_transfer_metum.save
                    _product_counter = 0
                  end  
                end  
              else
                raise 'No transfer options for this product.'  
              end 
            else  
              _stock_transfer_metum[:stock_transfer_id] = @stock_transfer.id
              _product_color_size = c.split('_')
              _stock_transfer_metum[:product_id] = _product_color_size[0]
              if _product_color_size[1] != '0'
                _stock_transfer_metum[:color_id] = _product_color_size[1]
                _stock_transfer_metum[:color_name] = Color.find(_product_color_size[1]).name
              end
              if _product_color_size[2] != '0'
                _stock_transfer_metum[:size_id] = _product_color_size[2]
                _stock_transfer_metum[:size_name] = Size.find(_product_color_size[2]).name
              end
              _stock_transfer_metum[:stock_transfer_unit] = Product.find(_product_color_size[0]).basic_unit_id
              _stock_transfer_metum[:quantity_transfered] = params["quantity#{c}"]
              _stock_transfer_metum[:quantity_received] = params["quantity#{c}"]  
              _stock_transfer_metum.save
            end  
          else
            _product_counter = params["quantity#{c}"]
            _transfer_options = Stock.product_debit_options(params[:primary_store_id], c)
            if _transfer_options.present?
              _transfer_options.each do |at|
                if _product_counter.to_f >= at.available_stock.to_f
                  _stock_transfer_metum = StockTransferMetum.new
                  _stock_transfer_metum[:stock_transfer_id] = @stock_transfer.id
                  _stock_transfer_metum[:product_id] = c
                  _stock_transfer_metum[:quantity_transfered] = at.available_stock
                  _stock_transfer_metum[:quantity_received] = at.available_stock 
                  _stock_transfer_metum[:sku] = at.sku
                  _stock_transfer_metum.save
                  _product_counter = _product_counter.to_f - (at.available_stock).to_f
                elsif _product_counter.to_f > 0
                  _stock_transfer_metum = StockTransferMetum.new
                  _stock_transfer_metum[:stock_transfer_id] = @stock_transfer.id
                  _stock_transfer_metum[:product_id] = c
                  _stock_transfer_metum[:quantity_transfered] = _product_counter
                  _stock_transfer_metum[:quantity_received] = _product_counter
                  _stock_transfer_metum[:sku] = at.sku
                  _stock_transfer_metum.save
                  _product_counter = 0
                end  
              end  
            else
              raise 'No transfer options for this product.'  
            end   
          end
        end
      end
      redirect_to store_stock_transfer_steps_path(@store,@stock_transfer), notice: 'Stock transfer initiated'
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to store_path(@store), alert: e.message
    end  
  end

  def custom_create_for_boxing
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        @stock_transfer = StockTransfer.new
        @store = Store.find(params[:primary_store_id])
        @stock_transfer[:transfer_type]=params[:transfer_type]
        @stock_transfer[:secondary_store_id]=params[:secondary_store_id]
        @stock_transfer[:primary_store_id]=params[:primary_store_id]
        @stock_transfer[:boxing_id]=params[:boxing_id]
        @stock_transfer[:vehicle_id]=params[:vehicle_id]
        @stock_transfer[:status] = "0"
        @stock_transfer[:activity_id] = 2
        @stock_transfer.save
        params[:checked_raw].each do |c|
          if params[:business_type] == 'by_catalog'
            _stock_transfer_metum = StockTransferMetum.new
            _stock_transfer_metum[:stock_transfer_id] = @stock_transfer.id
            _stock_transfer_metum[:product_id] = c
            _stock_transfer_metum[:quantity_transfered] = params["quantity#{c}"]
            _stock_transfer_metum[:quantity_received] = params["quantity#{c}"]  
            _stock_transfer_metum[:sku] = params["sku#{c}"]
            _stock_transfer_metum.save
          else
            _product_counter = params["quantity#{c}"]
            _transfer_options = Stock.product_debit_options(params[:primary_store_id], c)
            if _transfer_options.present?
              _transfer_options.each do |at|
                if _product_counter.to_f >= at.available_stock.to_f
                  _stock_transfer_metum = StockTransferMetum.new
                  _stock_transfer_metum[:stock_transfer_id] = @stock_transfer.id
                  _stock_transfer_metum[:product_id] = c
                  _stock_transfer_metum[:quantity_transfered] = at.available_stock
                  _stock_transfer_metum[:quantity_received] = at.available_stock 
                  _stock_transfer_metum[:sku] = at.sku
                  _stock_transfer_metum.save
                  _product_counter = _product_counter.to_f - (at.available_stock).to_f
                elsif _product_counter.to_f > 0
                  _stock_transfer_metum = StockTransferMetum.new
                  _stock_transfer_metum[:stock_transfer_id] = @stock_transfer.id
                  _stock_transfer_metum[:product_id] = c
                  _stock_transfer_metum[:quantity_transfered] = _product_counter
                  _stock_transfer_metum[:quantity_received] = _product_counter
                  _stock_transfer_metum[:sku] = at.sku
                  _stock_transfer_metum.save
                  _product_counter = 0
                end  
              end  
            else
              raise 'No transfer options for this product.'  
            end   
          end
          _stock_transfer_metum.save
        end
      end
      redirect_to store_stock_transfer_steps_path(@store,@stock_transfer), notice: 'Stock transfer initiated'
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to store_path(@store), alert: e.message
    end  
  end
  def update_picked_quantity
    puts params
    _stock_transfer_meta = StockTransferMetum.find(params[:id])
    puts _stock_transfer_meta.inspect
    if _stock_transfer_meta.present?
      _stock_transfer_meta.update_attribute(:picked_quantity,(_stock_transfer_meta.picked_quantity+params[:picked_quantity].to_i))
    end
    respond_to do |format|
      format.json{render json:{data:_stock_transfer_meta,status:"ok"}}
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

  def set_product_transfer_info(pro_id, store, trans_qty, product_unit)
    _arr = {}
    _arr[:transfer_bulk_qty] = trans_qty
    if product_unit.to_i > 0
      unit = ProductUnit.find(product_unit.to_i)
      trans_qty = trans_qty.to_f * unit.multiplier.to_f
      _arr[:product_unit_name] = unit.short_name
    end
    _product = Product.find(pro_id)
    _arr[:product_id] = _product.id
    _arr[:product_name] = _product.name
    _arr[:basic_unit] = _product.basic_unit
    _arr[:product_unit] = product_unit
    _arr[:current_stock] = StockUpdate.current_stock(store,pro_id)
    _arr[:transfer_qty] = trans_qty
    _arr[:transfer_options] = Stock.product_debit_options(store, pro_id)
    _arr[:secondary_current_stock] = SecondaryStock.current_unit_stock(store, pro_id, product_unit)
    _arr[:secondary_transfer_options] = SecondaryStock.debit_options(store, pro_id, product_unit)

    return _arr
  end

  def set_menu_product_transfer_info(menu_pro_id,store_id, _mp_qty,_product_arry,_menu_pro_arr)
    _mp_sub_pros = ProductManagement::get_sub_products(menu_pro_id)
    _mp_sub_pros.each do |mk|
      _raw_pro_id = mk['raw_product_id']
      _raw_pro_unit = ProductManagement::get_product_unit_details(mk['raw_product_unit'])
      _pro_unit_multiplier = _raw_pro_unit.multiplier #Getting the product multiplier
      _total_raw_qty = (_pro_unit_multiplier.to_f)*(mk['raw_product_quantity'].to_f)*(_mp_qty.to_f)
      if _product_arry && _product_arry.has_key?(_raw_pro_id)
         _product_arry[_raw_pro_id][:transfer_qty] = ((_product_arry[_raw_pro_id][:transfer_qty]).to_f + _total_raw_qty)
      else
        _raw_pro_details = ProductManagement::get_product_details_by_id(_raw_pro_id)
        _raw_arr = {}
        _raw_arr[:product_id]   = _raw_pro_id
        _raw_arr[:product_name] = _raw_pro_details.name
        _raw_arr[:basic_unit] = _raw_pro_details.basic_unit
        _raw_arr[:current_stock] = StockUpdate.current_stock(store_id,_raw_pro_id)
        _raw_arr[:transfer_qty] = _total_raw_qty
        _raw_arr[:transfer_options] = Stock.product_debit_options(store_id, _raw_pro_id)
        _product_arry[_raw_pro_id] = _raw_arr
      end
      _menu_arr = {}
      _menu_arr[:menu_product_id] = menu_pro_id
      _menu_arr[:menu_product_qty] = _mp_qty
      _menu_pro_arr[menu_pro_id] = _menu_arr
    end
  end

  def update_requisition_log(_product_id,_log_id,_total_qty,_color_id=nil,_size_id=nil)
    _log = StoreRequisitionLog.find(_log_id)
    if _log.sent_product_details.nil?
      _sent_status = {}
      _log.sent_product_count = 0
    else
      _sent_status = JSON.parse(_log.sent_product_details)
    end
    _color_id = 0 if _color_id == nil or _color_id == ''
    _size_id = 0 if _size_id == nil or _size_id == ''
    _sent_status["#{_product_id}_#{_color_id}_#{_size_id}"]=_total_qty
    _new_status = JSON.generate(_sent_status)
    _log.update_attribute(:sent_product_details, _new_status)
    _log.update_attribute(:sent_product_count, (_log.sent_product_count + 1))
    _new_log = StoreRequisitionLog.find(_log_id)
    if _log.product_count == _new_log.sent_product_count
      _log.update_attribute(:status, "4") #All product transfer complete
    end
  end

  def check_transfer_possibility(store_id,product_id,_total_qty)
    _current_stock = StockUpdate.current_stock(store_id,product_id)
    if _current_stock.to_f < _total_qty.to_f
      _product = Product.find(product_id)
      raise 'Current stock of '+_product.name+' is not sufficient for this transfer.'
      return 1
    else
      return 0
    end
  end

  def receive_transfer_items _stock_transfer, receiving_store_id
    _stock_transfer.stocks.each do |stk|
      invoice_item = _stock_transfer.stock_transfer_invoice.stock_transfer_invoice_meta.by_product(stk.product_id).first
      invoice_price = invoice_item.tax_group_id.present? ? invoice_item.price_with_tax : invoice_item.price
      _new_stock = Stock.save_stock(stk.product_id,receiving_store_id,invoice_price.to_f,stk.stock_debit.to_f,_stock_transfer.id,'stock_transfer',stk.stock_debit.to_f,0,nil,nil,nil)
      stk.secondary_stocks.map { |e|  SecondaryStock.credit(_new_stock, e.product_unit_id, e.stock_debit) } if stk.secondary_stocks.present?
    end
  end
end
