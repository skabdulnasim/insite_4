class StockAuditsController < ApplicationController
  load_and_authorize_resource
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper  
  include StockAuditsHelper
  layout "material"

  before_filter :set_module_details
  before_filter :set_store, only: [:new, :create, :show, :audit_options, :update]
  #before_filter :get_current_user, only: [:new]
  
  def show
    @stock_audit = StockAudit.find(params[:id])
  end

  def new
    @categories = Category.all
    if params[:business_type] == "by_catalog"
      if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
        if AppConfiguration.get_config_value('stock_identity') == "enabled"
          @stock_products = Stock.set_store(@store.id).has_sell_price_with_tax.select("product_id,sku,stock_identity,color_name,size_name").group("product_id,sku,stock_identity,color_name,size_name")
          @stock_products = @stock_products.filter_by_sku(params[:sku_filter]) if params[:sku_filter].present?
          @stock_products = @stock_products.filter_by_product_name(@stock_products,params[:filter]) if params[:filter].present?
          @stock_products = @stock_products.filter_by_product_category(@stock_products,params[:product_category]) if params[:product_category].present?
          @stock_products = @stock_products.filter_by_product_id(@stock_products,params[:product_id_filter]) if params[:product_id_filter].present?
          smart_listing_create :products, @stock_products, partial: "products/product_catalog_stock_identity_smartlist", default_sort: {product_id: "desc"}
        else
          # @stock_products = Stock.set_store(@store.id).select("product_id,sku").group("product_id,sku")
          @stock_products = Stock.set_store(@store.id).has_sell_price_with_tax.select("product_id,color_id,size_id,sell_price_with_tax,sku,model_number,batch_no").uniq
          #@stock_products = Stock.available.set_store(@store.id).includes(:product).where("products.business_type = ?", params[:business_type])
          @stock_products = @stock_products.filter_by_sku(params[:sku_filter]) if params[:sku_filter].present?
          @stock_products = @stock_products.filter_by_product_name(@stock_products,params[:filter]) if params[:filter].present?
          @stock_products = @stock_products.filter_by_product_category(@stock_products,params[:product_category]) if params[:product_category].present?
          @stock_products = @stock_products.filter_by_product_id(@stock_products,params[:product_id_filter]) if params[:product_id_filter].present?
          #@stock_products = Stock.check_stock_status(params[:store_id], params[:stock_filter], current_user.unit_id).includes(:product).where("products.business_type = ?", params[:business_type]) if params[:stock_filter].present?
          @stock_products = @stock_products.check_stock_status_for_barcode_enabled(params[:stock_filter],params[:store_id],current_user.unit_id) if params[:stock_filter].present?
          smart_listing_create :products, @stock_products, partial: "products/product_catalog_sku_smartlist", default_sort: {product_id: "desc"}
        end
        @stock_products.each do |product|
          puts product.inspect
        end
      else
        if AppConfiguration.get_config_value('stock_identity') == "enabled"
          @stock_products = Stock.set_store(@store.id).select("product_id,sku,stock_identity").group("product_id,sku,stock_identity")
          smart_listing_create :products, @stock_products, partial: "products/product_catalog_stock_identity_smartlist", default_sort: {product_id: "desc"}
        else
          @all_products = @store.products.present? ? @store.products : Product.get_all
          #product_scope = @all_products.check_stock_status(@store.id,"1",current_user.unit_id).by_business_type(params[:business_type])
          product_scope = @all_products
          product_scope = product_scope.check_stock_status(@store.id,params[:stock_filter],current_user.unit_id) if params[:stock_filter]
          product_scope = product_scope.filter_by_product_category(params[:product_category]) if params[:product_category].present?
          product_scope = product_scope.filter_by_string(params[:filter]) if params[:filter].present?
          @stock_products = product_scope.filter_by_product_id(params[:product_id_filter]) if params[:product_id_filter].present?
          smart_listing_create :products, product_scope, partial: "products/product_selection_smartlist", default_sort: {id: "desc"}
        end
      end
    else
      stock_product = Stock.check_stock_status(@store.id,'1',current_user.unit_id).includes(:product).where("products.business_type = ?", params[:business_type])
      stock_product = stock_product.filter_by_sku(params[:sku_filter]) if params[:sku_filter].present?
      stock_product = stock_product.filter_by_product_name(stock_product,params[:filter]) if params[:filter].present?
      stock_product = stock_product.filter_by_product_category(stock_product,params[:product_category]) if params[:product_category].present?
      smart_listing_create :products, stock_product, partial: "products/product_sku_smartlist", default_sort: {product_id: "desc"}
    end  
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end    
  end

  def audit_options
    params[:stock_audits].each do |audit_product|
      puts audit_product
    end
    begin
      @business_type = params[:business_type]
      @selected_products = Array.new
      raise 'No products selected for audit.' if params[:checked_products].nil?
      params[:stock_audits].each do |audit_product|
        set_product_audit_info(audit_product,@store.id,@selected_products,@business_type,params["transfer_meta#{audit_product['product_id']}"])
      end
      @stock_audit = StockAudit.initiate_audit_procedure(@store.id,@selected_products,current_user.id,@business_type)
      puts @selected_products
      redirect_to store_stock_audit_steps_path(@store,@stock_audit)     
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_store_stock_audit_path(@store), alert: e.message.to_s
    end
  end

  def create
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        raise 'No products selected for audit.' if params[:checked_products].nil?
        @products_arr = Array.new
        params[:checked_products].each do |cp| #Step 1 : Build product total audit quantity and array of effecting stock entries
          build_products_audit_info_hash(@products_arr,cp,params)
          if params["transfer_meta#{cp}"].present?
            transfer_meta = StockTransferMetum.find(params["transfer_meta#{cp}"])
            transfer_meta.update_attributes(:status => "stock_audit")
          end  
        end
        StockAudit.initiate_audit_procedure(@store.id,@products_arr,current_user.unit_id,params[:business_type])
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_store_stock_audit_path(@store), alert: e.message.to_s
    else
      redirect_to store_path(@store), notice: "Stock audit was successfully submitted for approval."  
    end   
  end

  #Use log: Updating audit status
  def update
    puts params
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        _stock_audit = StockAudit.find(params[:id])
        _status = params[:status]
        _stock_audit.update_attributes(:status => _status, :audit_reviewed_by => current_user.id)
        if _status == "2"
          if _stock_audit.business_type == "by_catalog"
            if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
              _stock_audit.stock_audit_metas.each do |sam|
                if AppConfiguration.get_config_value('stock_identity') == 'enabled'
                  _stock_id = sam.stock_id
                  _current_stock = Stock.find(_stock_id).available_stock
                  _current_stock_date = Stock.find(_stock_id).updated_at
                else
                  _condition_hash = build_condition_hash(sam.color_id,sam.size_id,sam.model_no,sam.batch_no,sam.sell_price_with_tax)
                  _stock_details = Stock.get_product(sam.product_id).set_store(@store).by_sku(sam.sku).where(_condition_hash)
                  _current_stock = _stock_details.available.sum(:available_stock)
                  _current_stock_date = _stock_details.first.updated_at
                  puts _current_stock
                end
                if _current_stock_date > sam.created_at
                  sam.update_attributes(:stock_added => 0,:stock_consumed => 0, :current_stock_at_review => _current_stock)
                else
                  _stock_to_consume = (_current_stock.to_f - sam.counted_stock.to_f)
                  if _stock_to_consume < 0
                    if AppConfiguration.get_config_value('stock_identity') == 'enabled'
                      stock = Stock.save_stock(sam.product_id,_stock_audit.store_id,params["extra_stock_price_#{sam.product_id}"],_stock_to_consume.to_f.abs,_stock_audit.id,'stock_audit',_stock_to_consume.to_f.abs,0,params["expiry_date_#{sam.product_id}"],sam.sku,params["mfg_date#{sam.product_id}"],params["model_no#{sam.product_id}"],nil,nil,params["sale_price_#{sam.product_id}"],nil,nil,params["batch_no#{sam.product_id}"],'',sam.stock_identity)
                    else
                      stock = Stock.save_stock(sam.product_id,_stock_audit.store_id,params["extra_stock_price_#{sam.id}"],_stock_to_consume.to_f.abs,_stock_audit.id,'stock_audit',_stock_to_consume.to_f.abs,0,params["expiry_date_#{sam.id}"],sam.sku,params["mfg_date_#{sam.id}"],params["model_no#{sam.id}"],nil,nil,params["sale_price_#{sam.id}"],nil,nil,params["batch_no#{sam.id}"],'','')
                    end
                    sam.update_attributes(:stock_added => params["extra_stock_#{sam.id}"].to_f, :current_stock_at_review => _current_stock)
                    if AppConfiguration.get_config_value('retail_menu') == 'enabled' && AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
                      if UnitProduct.by_unit(current_user.unit_id).by_product(stock.product_id).present?
                        up = UnitProduct.by_unit(current_user.unit_id).by_product(stock.product_id).first
                        _limit_vtax = AppConfiguration.get_config('vtax_five_percent_limit').present? ? AppConfiguration.get_config('vtax_five_percent_limit').to_f : 1120
                        _total_amnt = 0
                        i = 1
                        @tax_array = up.tax_group.tax_classes
                        @tax_array.sort { |a, b|  a.ammount <=> b.ammount }
                        @tax_array.each do |tc|
                          if tc.tax_type == 'variable'
                            if self.sale_price_without_tax.to_f <= _limit_vtax
                              if i == 1
                                _total_amnt = _total_amnt + 2.5    
                              elsif i == 2
                                _total_amnt = _total_amnt + 2.5
                              end
                            else
                              if i == 3
                                _total_amnt = _total_amnt + 6
                              elsif i == 4
                                _total_amnt = _total_amnt + 6
                              end
                            end 
                          else
                            _total_amnt = _total_amnt + tc[:ammount].to_f  
                          end
                          i += 1
                        end
                        sell_price_without_tax = 0
                        sell_price_without_tax = (stock.sell_price_with_tax.to_f * 100)/(_total_amnt.to_f + 100)
                        if stock.batch_no.present?
                          lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_batch_no_and_mode_and_store_id(up.product_id,stock.sku,stock.expiry_date,sell_price_without_tax,stock.batch_no,0,stock.store_id)
                        else
                          lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_mode_and_store_id(up.product_id,stock.sku,stock.expiry_date,sell_price_without_tax,0,stock.store_id)
                        end   
                        if lot.present? && lot.mode == 0
                          stock_qty = sam.counted_stock.to_f
                          lot.update_attributes(:stock_qty => stock_qty)
                        else
                          lot = Lot.new
                          lot.unit_product_id = up.id
                          lot.menu_product_id = nil
                          lot.mode = 0
                          lot.sell_price_without_tax = sell_price_without_tax
                          lot.sku = stock.sku
                          lot.stock_qty = sam.counted_stock.to_f
                          lot.product_id = stock.product_id
                          lot.expiry_date = stock.expiry_date
                          lot.stock_id = stock.id
                          lot.procured_price = stock.price
                          lot.mrp = params["mrp_price_#{sam.product_id}"]
                          lot.menu_card_id = nil
                          lot.color_name = stock.color_name
                          lot.size_name = stock.size_name
                          lot.size_id = stock.size_id
                          lot.color_id = stock.color_id
                          lot.lot_desc = "Description"
                          lot.batch_no = stock.batch_no
                          lot.store_id = stock.store_id
                          lot.save  
                        end
                      end
                    end
                  elsif _stock_to_consume == 0
                    sam.update_attributes(:stock_added => 0,:stock_consumed => 0, :current_stock_at_review => _current_stock)
                  else
                    if AppConfiguration.get_config_value('stock_identity') == 'enabled'
                      Stock.reduce_product_stock_by_stock_id(sam.stock_id,_stock_to_consume,_stock_audit.id,"stock_audit",0)
                    else
                      Stock.reduce_product_stock(_stock_audit.store_id,sam.product.id,_stock_to_consume,_stock_audit.id,"stock_audit",sam.sku,'','','','','','','')
                    end
                    if AppConfiguration.get_config_value('retail_menu') == 'enabled'
                      menu_cards = MenuCard.set_unit(current_user.unit_id).active
                      menu_cards.each do |mc|
                        if MenuProduct.by_menu_card(mc.id).set_product(sam.product_id).present?
                          mp = MenuProduct.by_menu_card(mc.id).set_product(sam.product_id).first
                          lot = Lot.find_by_menu_product_id_and_sku(mp.id,sam.sku)
                          if lot.present? && lot.mode == 0
                            stock_qty = sam.counted_stock.to_f
                            lot.update_attributes(:stock_qty => stock_qty)
                          end
                        end
                      end
                    end        
                    sam.update_attributes(:stock_consumed => _stock_to_consume, :current_stock_at_review => _current_stock)
                  end
                end
              end
            else
              _stock_audit.stock_audit_metas.each do |sam|
                if AppConfiguration.get_config_value('stock_identity') == 'enabled'
                  _stock_id = sam.stock_identity.split('-')[5]
                  _current_stock = Stock.find(_stock_id).available_stock
                  _current_stock_date = Stock.find(_stock_id).updated_at
                else
                  _stock_status = StockUpdate.by_product(sam.product_id).by_store(_stock_audit.store_id)
                  _current_stock_date = _stock_status.present? ? _stock_status.last.created_at : sam.created_at
                  #_current_stock_date = StockUpdate.by_product(sam.product_id).by_store(_stock_audit.store_id).last.created_at
                  _current_stock = StockUpdate.current_stock(_stock_audit.store_id,sam.product_id)
                  
                end
                if _current_stock_date > sam.created_at
                  sam.update_attributes(:stock_added => 0,:stock_consumed => 0, :current_stock_at_review => _current_stock)
                else
                  puts "current_stock : #{_current_stock}"
                  puts "counted_stock_stock : #{sam.counted_stock}"
                  _stock_to_consume = (_current_stock.to_f - sam.counted_stock.to_f)
                  if _stock_to_consume <= 0 
                    if _stock_to_consume == 0
                      sam.update_attributes(:stock_added => 0,:stock_consumed => 0, :current_stock_at_review => _current_stock)
                    else
                      Stock.save_stock(sam.product_id,_stock_audit.store_id,params["extra_stock_price_#{sam.product_id}"],params["extra_stock_#{sam.product_id}"],_stock_audit.id,'stock_audit',params["extra_stock_#{sam.product_id}"],0,nil,nil,nil)
                      sam.update_attributes(:stock_added => params["extra_stock_#{sam.product_id}"].to_f, :current_stock_at_review => _current_stock)
                    end
                  else
                    Stock.reduce_product_stock(_stock_audit.store_id,sam.product.id,_stock_to_consume,_stock_audit.id,"stock_audit",nil,'','','','','','','')
                    sam.update_attributes(:stock_consumed => _stock_to_consume, :current_stock_at_review => _current_stock)
                  end
                end
              end #End of product for each
            end  
          else
            _stock_audit.stock_audit_metas.each do |sam|
              _current_stock_date = StockUpdate.by_product(sam.product_id).by_store(_stock_audit.store_id).last.created_at
              _current_stock = StockUpdate.current_sku_stock(_stock_audit.store_id,sam.product_id,sam.sku)
              if _current_stock_date > sam.created_at
                sam.update_attributes(:stock_added => 0,:stock_consumed => 0, :current_stock_at_review => _current_stock)
              else
                _stock_to_consume = (_current_stock.to_f - sam.counted_stock.to_f)
                if _stock_to_consume < 0
                  Stock.save_stock(sam.product_id,_stock_audit.store_id,params["extra_stock_price_#{sam.sku}"],params["extra_stock_#{sam.sku}"],_stock_audit.id,'stock_audit',params["extra_stock_#{sam.sku}"],0,nil,sam.sku,nil)
                  sam.update_attributes(:stock_added => params["extra_stock_#{sam.sku}"].to_f, :current_stock_at_review => _current_stock)
                elsif _stock_to_consume == 0
                  sam.update_attributes(:stock_added => 0,:stock_consumed => 0, :current_stock_at_review => _current_stock)
                else
                  Stock.reduce_sku_product_stock(_stock_audit.store_id,sam.product_id,sam.sku,_stock_to_consume,_stock_audit.id,"stock_audit")
                  sam.update_attributes(:stock_consumed => _stock_to_consume, :current_stock_at_review => _current_stock)
                end
              end
            end
          end  
          respond_to do |format|
            format.html { redirect_to store_path(@store), notice: 'Stock audit has been successfully approved.' }
          end
        elsif _status == "3"
          respond_to do |format|
            format.html { redirect_to store_path(@store), notice: 'Stock audit has been successfully rejected.' }
          end
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to store_path(@store), alert: e.message.to_s 
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
  
  def set_product_audit_info(product_hash,store_id,selected_products,business_type,transfer_meta_id)

    _arr = {}
    if business_type == "by_catalog"
      if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
        if AppConfiguration.get_config_value('stock_identity') == 'enabled'
          _arr[:stock_id] = pro_id
          _stock = Stock.find(pro_id)
          _arr[:product] = _stock.product
          _arr[:product_id] = _stock.product.id
          _arr[:stock_identity] = _stock.stock_identity
        else
          #_arr[:product] = _stock.product
          _arr[:sell_price_with_tax] = product_hash["price"]
          _arr[:product_id] = product_hash["product_id"]
          _arr[:color_id] = product_hash["color_id"] != "na" ? product_hash["color_id"] : nil
          _arr[:size_id] = product_hash["size_id"] != "na" ? product_hash["size_id"] : nil
          _arr[:model_number] = product_hash["model_number"] != "na" ? product_hash["model_number"] : nil
          _arr[:batch_no] = product_hash["batch_no"] != "na" ? product_hash["batch_no"] : nil
        end
        _arr[:counted_stock] = product_hash["quantity"]
        _arr[:transfer_meta_id] = transfer_meta_id
        _arr[:sku] = product_hash["sku"]
      else
        if AppConfiguration.get_config_value('stock_identity') == 'enabled'
          _arr[:stock_identity] = pro_id
          pro_id = pro_id.split('-')[3]
        end
        _arr[:product] = Product.find(product_hash["product_id"])
        _arr[:product_id] = product_hash["product_id"]
        _arr[:counted_stock] = product_hash["quantity"]
        _arr[:transfer_meta_id] = transfer_meta_id
      end  
    else  
      _arr[:stock] = Stock.find(pro_id)
      _arr[:counted_stock] = quantity
    end
    selected_products.push(_arr)
  end

  def build_products_audit_info_hash(products_arr,cp,params)
    _arr = {}
    if params["business_type"] == "by_catalog"
      if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
        _arr[:product_id] = cp

        if AppConfiguration.get_config_value('stock_identity') == 'enabled'
          stock = Stock.find(cp)
          _arr[:stock_id] = cp
          _arr[:stock_identity] = params["stock_identity_#{cp}"]
          _arr[:product_id] = stock.product.id
        end
        _arr[:remarks] = params["remarks_#{cp}"]
        _arr[:reason_code] = params["reason_for_#{cp}"]
        _arr[:counted_stock] = params["quantity_#{cp}"]
        _arr[:sku] = params["sku_#{cp}"]
      else
        if AppConfiguration.get_config_value('stock_identity') == 'enabled'
          _arr[:stock_identity] = params["stock_identity_#{cp}"]
        end
        _arr[:product_id] = cp
        _arr[:reason_code] = params["reason_for_#{cp}"]
        _arr[:remarks] = params["remarks_#{cp}"]
        _arr[:counted_stock] = params["quantity_#{cp}"]
      end
    else     
      _arr[:product_id] = params["product_#{cp}"]
      _arr[:reason_code] = params["reason_for_#{cp}"]
      _arr[:remarks] = params["remarks_#{cp}"]
      _arr[:counted_stock] = params["quantity_#{cp}"]
      _arr[:sku] = params["sku_#{cp}"]
    end  
    products_arr.push(_arr)
  end
end