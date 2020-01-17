class StockPurchasesController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  load_and_authorize_resource :except => [:show]
  require 'smarter_csv'

  
  # layout 
  layout :set_layout

  before_filter :set_module_details

  # GET /stock_purchases/1
  # GET /stock_purchases/1.json
  def show
    @warehouse_rack = WarehouseMetum.order(:id)
    @site_title = AppConfiguration.get_config_value('site_title')
    @product_units = ProductUnit.all
    @stock_purchase = StockPurchase.find(params[:id])
    stocks = @stock_purchase.stocks.type_credit
    @store = Store.find(params[:store_id])
    @menu_cards = MenuCard.set_unit(@store.unit_id)
    @percentages = Percentage.all
    @input_tax_config = AppConfiguration.get_config_value('stock_input_tax')
    @input_tax_type = AppConfiguration.get_config_value('stock_input_tax_type')
    @stock_expiry_date = AppConfiguration.get_config_value('stock_expiry_date')
    @stock_purchase_product = @stock_purchase.stocks.type_credit
    smart_listing_create :stock_purchase_product, @stock_purchase_product,partial:"stock_purchases/stock_purchase_product_smartlist",page_sizes:[12]
    smart_listing_create :warehouse_racks, @warehouse_rack,partial:"stock_purchases/warehouse_rack_smartlist"
    smart_listing_create :stock_logs, @stock_purchase_product, partial: "stock_purchases/stock_logs"
    # @stock_purchase_product.each do |meta|
    #   puts "executed"
    # end
    
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @stock_purchase.to_json(:include => {:purchase_order => {:include => [:unit,:vendor,{:purchase_order_metum => {:include => [:product,:product_transaction_unit]}}]}} ) }
    end
  end

  # PUT /stock_purchases/1
  # PUT /stock_purchases/1.json

  def update
    begin
      @stock_purchase = StockPurchase.find(params[:id])
      _limit_vtax = AppConfiguration.get_config('vtax_five_percent_limit').present? ? AppConfiguration.get_config('vtax_five_percent_limit').to_f : 1120
      @store = Store.find(params[:store_id])
      _business_type = params[:business_type]
      ActiveRecord::Base.transaction do # Protective transaction block        
        uploaded_file = params[:csv_file]
        if uploaded_file.present?
          file_name = uploaded_file.tempfile.to_path.to_s
          uploaded_file_type = uploaded_file.original_filename.split('.')
          raise "File format should be csv." unless uploaded_file_type[1] == "csv"
          @po_products = @stock_purchase.purchase_order.purchase_order_metum.map{|m| m.product_id}
          @csv_product_array = Array.new
          SmarterCSV.process(file_name) do |header| # =>  Data  validation
            @csv_product_array = validate_csv_data(header.first,@po_products,@csv_product_array) 
          end
          SmarterCSV.process(file_name) do |header| # =>  Data  processing
            StockPurchase.stock_csv_upload(header.first, @store.id, params[:stock_transaction_id], params[:stock_transaction_type])
          end
          StockPurchase.check_po_count_status(params[:stock_transaction_id],params[:po_all_pro_count],@csv_product_array.count,params[:received_count])
        else
          raise 'No Product checkbox selected.' unless !params[:selected_po_srials].nil?
          if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
            params[:selected_po_srials].each do |pos|
              po_serial = pos.split("_")[0]
              _pom = PurchaseOrderMetum.find(po_serial)
              _product = Product.find(_pom.product_id)
              raise "#{_product.name} does not belongs to #{current_user.unit.unit_name} outlet" unless UnitProduct.by_unit(current_user.unit_id).by_product(_pom.product_id).present?
            end
          end  

          params[:selected_po_srials].each do |pos|
            po_serial = pos.split("_")[0]
            _pom = PurchaseOrderMetum.find(po_serial)
            _product = Product.find(_pom.product_id)
            _mfg_date = params["mfg_date_#{pos}"].present? ? params["mfg_date_#{pos}"] : Date.today.strftime("%Y-%m-%d")
            item_basic_qty = 0
            if params["input_quantity_#{pos}"].present?
              params["input_quantity_#{pos}"].map { |e| item_basic_qty += params["input_quantity_#{pos}_#{e}"].to_f * (ProductUnit.find(e)).multiplier }
            else
              item_basic_qty = params["pro_qty_#{pos}"]
            end
            # Saving stock
            _stock = 0
            if _product.business_type == "by_mrp"
              _stock = Stock.save_stock(_pom.product_id,@store.id,params["pro_cog_#{pos}"],item_basic_qty,@stock_purchase.id,"stock_purchase",item_basic_qty,0,nil,params["pro_sku_#{pos}"],nil)
              sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"] : format('%08d', _stock.id)
              StockDefination.save_stock_defination(_stock.id, nil, nil, nil, params["pro_mrp_#{pos}"], 0, sku, params["pro_description_#{pos}"])
              _product.update_attribute(:hsn_code, params["pro_hsn_code_#{pos}"])
              params["input_quantity_#{pos}"].map{|iq| SecondaryStock.credit(_stock, iq, params["input_quantity_#{pos}_#{iq}"])} if params["input_quantity_#{pos}"].present?
              params["tax_class_#{pos}"].map{|tc| StockTax.add_stock_tax(_stock.id, tc, params["tax_class_#{tc}_#{pos}"], params["tax-on-#{pos}-#{tc}"])} if params["tax_class_#{pos}"].present?
              _product_tax = params["tax_class_#{pos}"].present? ? params["tax_class_#{pos}"].map{ |e| params["tax_class_#{e}_#{pos}"].to_f }.reduce(0, :+) : 0  
              StockPrice.add_stock_price(_stock.id, params["pro_price_#{pos}"], params["pro_mrp_#{pos}"], _pom.product_id, params["pro_pwot_#{pos}"], _product_tax, params["pro_additional_cost_#{pos}"], params["pro_price_wt_#{pos}"], params["addon_remarks_#{pos}"],params["pro_dicount_#{pos}"],params["sales_percentage_#{pos}"],params["retail_price_#{pos}"])
            
            elsif _product.business_type == "by_weight"
              _stock = Stock.save_stock(_pom.product_id,@store.id,params["pro_cog_#{pos}"],item_basic_qty,@stock_purchase.id,"stock_purchase",item_basic_qty,0,nil,params["pro_sku_#{pos}"],nil)
              sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"] : format('%08d', _stock.id)
              StockDefination.save_stock_defination(_stock.id, params["pro_wet_#{pos}"], params["pro_unit_id_#{pos}"], params["pro_mc_#{pos}"], nil, params["pro_wstg_#{pos}"], sku, params["pro_description_#{pos}"])
              _product.update_attribute(:hsn_code, params["pro_hsn_code_#{pos}"])
              params["input_quantity_#{pos}"].map{|iq| SecondaryStock.credit(_stock, iq, params["input_quantity_#{pos}_#{iq}"])} if params["input_quantity_#{pos}"].present?
              params["tax_class_#{pos}"].map{|tc| StockTax.add_stock_tax(_stock.id, tc, params["tax_class_#{tc}_#{pos}"], params["tax-on-#{pos}-#{tc}"])} if params["tax_class_#{pos}"].present?
              _product_tax = params["tax_class_#{pos}"].present? ? params["tax_class_#{pos}"].map{ |e| params["tax_class_#{e}_#{pos}"].to_f }.reduce(0, :+) : 0  
              StockPrice.add_stock_price(_stock.id, params["pro_price_#{pos}"], params["pro_mrp_#{pos}"], _pom.product_id, params["pro_pwot_#{pos}"], _product_tax, params["pro_additional_cost_#{pos}"], params["pro_price_wt_#{pos}"], params["addon_remarks_#{pos}"],params["pro_dicount_#{pos}"],params["sales_percentage_#{pos}"],params["retail_price_#{pos}"])
           
            elsif _product.business_type == "by_bulk_weight"
              _stock = Stock.save_stock(_pom.product_id,@store.id,params["pro_cog_#{pos}"],params["pro_wet_#{pos}"],@stock_purchase.id,"stock_purchase",params["pro_wet_#{pos}"],0,nil,params["pro_sku_#{pos}"],nil)
              sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"] : format('%08d', _stock.id)
              StockDefination.save_stock_defination(_stock.id, params["pro_wet_#{pos}"], params["pro_unit_id_#{pos}"], params["pro_mc_#{pos}"], nil, params["pro_wstg_#{pos}"], sku, params["pro_description_#{pos}"])
              _product.update_attribute(:hsn_code, params["pro_hsn_code_#{pos}"])
              params["input_quantity_#{pos}"].map{|iq| SecondaryStock.credit(_stock, iq, params["input_quantity_#{pos}_#{iq}"])} if params["input_quantity_#{pos}"].present?
              params["tax_class_#{pos}"].map{|tc| StockTax.add_stock_tax(_stock.id, tc, params["tax_class_#{tc}_#{pos}"], params["tax-on-#{pos}-#{tc}"])} if params["tax_class_#{pos}"].present?
              _product_tax = params["tax_class_#{pos}"].present? ? params["tax_class_#{pos}"].map{ |e| params["tax_class_#{e}_#{pos}"].to_f }.reduce(0, :+) : 0  
              StockPrice.add_stock_price(_stock.id, params["pro_price_#{pos}"], params["pro_mrp_#{pos}"], _pom.product_id, params["pro_pwot_#{pos}"], _product_tax, params["pro_additional_cost_#{pos}"], params["pro_price_wt_#{pos}"], params["addon_remarks_#{pos}"],params["pro_dicount_#{pos}"],params["sales_percentage_#{pos}"],params["retail_price_#{pos}"])
           
            elsif _product.business_type == "by_catalog"
              if params["pro_sku_#{pos}"].present?
                sku = params["pro_sku_#{pos}"].strip
              else
                sku = nil
              end 
              expiry_date = params["expiry_date_#{pos}"].present? ? params["expiry_date_#{pos}"] : "2040-02-02"
              checked_raw_color_size_product_params = []
              flag = 0
              checked_raw_color_size_product_params = params["checked_raw_color_size_product_#{pos}"] if params["checked_raw_color_size_product_#{pos}"].present?
              if checked_raw_color_size_product_params.present?
                checked_raw_color_size_product_params.each do |color_size|
                  if params["product_color_size_quantity_#{pos}_#{color_size}"] != "0"
                    flag+=1
                  end
                end
                if flag==0
                  checked_raw_color_size_product_params.clear
                end
              end
              if !checked_raw_color_size_product_params.empty? && params["pro_qty_#{pos}"].present?
                params["checked_raw_color_size_product_#{pos}"].each do |color_size|
                  color_id = color_size.split('_')[0]
                  if color_id.to_i > 0
                    color_name = Color.find(color_id).name
                  else
                    color_name = ''
                    color_id = ''
                  end
                  size_id = color_size.split('_')[1]
                  if size_id.to_i > 0
                    size_name = Size.find(size_id).name
                  else
                    size_name = ''
                    size_id = ''
                  end  
                  csp_quantity = params["product_color_size_quantity_#{pos}_#{color_size}"]
                  if csp_quantity.to_f > 0
                    _stock = Stock.save_stock(_pom.product_id,@store.id,params["pro_price_wt_#{pos}"],csp_quantity,@stock_purchase.id,"stock_purchase",csp_quantity,0,expiry_date,sku,_mfg_date,params["model_number_#{pos}"],size_name,color_name,params["retail_price_#{pos}"],color_id,size_id,params["batch_no_#{pos}"],params["free_quantity_#{pos}"],'',params["p_gender_#{pos}"])
                    if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
                      expiry_date = params["expiry_date_#{pos}"].present? ? params["expiry_date_#{pos}"] : "2040-02-02"
                      # if AppConfiguration.get_config_value('uniqe_sku_for_stock') == 'enabled'
                      #   sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"].strip : format('%010d', _stock.id)
                      # else 
                      #   _sku = "#{_pom.product_id}""#{color_id}""#{size_id}" 
                      #   sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"].strip : format('%010d', _sku) 
                      # end 

                      if AppConfiguration.get_config_value('uniqe_sku_for_stock') == 'enabled' 
                        sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"].strip : format('%010d', _stock.id)
                      elsif AppConfiguration.get_config_value('uniqe_stock_for_color_size') == 'enabled'
                        _sku = "#{_pom.product_id}""#{color_id}""#{size_id}"
                        sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"].strip : format('%010d', _sku)
                      elsif AppConfiguration.get_config_value('sku_algorithm') == 'enabled'
                        sku = ''
                        sku = "#{sku}""#{AppConfiguration.get_config('sku_prefix_limit')}" if AppConfiguration.get_config_value('sku_prefix') == 'enabled' 
                        sku = "#{sku}#{_stock.p_gender}#{_stock.product.category.code}#{_stock.product.brand_code}" if AppConfiguration.get_config_value('category_code') == 'enabled'
                        sku = "#{sku}#{_stock.stock_transaction.purchase_order.vendor.code}" if AppConfiguration.get_config_value('vendor_code') == 'enabled'
                        sku = "#{sku}#{_stock.color.code}" if AppConfiguration.get_config_value('color_code') == 'enabled' and _stock.color.present?
                        sku = "#{sku}#{_stock.size.code}" if AppConfiguration.get_config_value('size_code') == 'enabled' and _stock.size.present?
                        sku = "#{sku}#{_stock.product.p_code}" if AppConfiguration.get_config_value('product_serial') == 'enabled'
                      end

                      _stock.update_column(:sku, sku)
                    end
                    _product.update_attribute(:hsn_code, params["pro_hsn_code_#{pos}"])
                    params["input_quantity_#{pos}"].map{|iq| SecondaryStock.credit(_stock, iq, params["input_quantity_#{pos}_#{iq}"])} if params["input_quantity_#{pos}"].present?
                    params["tax_class_#{pos}"].map{|tc| StockTax.add_stock_tax(_stock.id, tc, params["tax_class_#{tc}_#{pos}"], params["tax-on-#{pos}-#{tc}"])} if params["tax_class_#{_pom.product_id}"].present?
                    _product_tax = params["tax_class_#{pos}"].present? ? params["tax_class_#{pos}"].map{ |e| params["tax_class_#{e}_#{pos}"].to_f }.reduce(0, :+) : 0  
                    StockPrice.add_stock_price(_stock.id, params["pro_price_#{pos}"], params["pro_mrp_#{pos}"], _pom.product_id, params["pro_pwot_#{pos}"], _product_tax, params["pro_additional_cost_#{pos}"], params["pro_price_wt_#{pos}"], params["addon_remarks_#{pos}"],params["pro_dicount_#{pos}"],params["sales_percentage_#{pos}"],params["retail_price_#{pos}"],params["margin_on_mrp_#{pos}"],params["purchase_cost_#{pos}"],params["volume_discount_#{pos}"],params["scheme_discount_#{pos}"],params["scheme_discount_by_amount_#{pos}"],params["discount_on_mrp_#{pos}"])
                    if AppConfiguration.get_config_value('retail_menu') == 'enabled'
                      if UnitProduct.by_unit(current_user.unit_id).by_product(_pom.product_id).present?
                        up = UnitProduct.by_unit(current_user.unit_id).by_product(_pom.product_id).first
                        _total_amnt = 0
                        i = 1
                        @tax_array = up.tax_group.tax_classes
                        @tax_array.sort { |a, b|  a.ammount <=> b.ammount }
                        @tax_array.each do |tc|
                          if tc.tax_type == 'variable'
                            if params["retail_price_#{pos}"].to_f <= _limit_vtax
                              if i == 1
                                _total_amnt = _total_amnt + 2.5    
                              elsif i == 2
                                _total_amnt = _total_amnt + 2.5
                              end
                            else
                              if i == 3
                                if tc.ammount.to_f == 9.00 || tc.ammount.to_f == 9
                                  _total_amnt = _total_amnt + 9
                                else  
                                  _total_amnt = _total_amnt + 6
                                end 
                              elsif i == 4
                                if tc.ammount.to_f == 9.00 || tc.ammount.to_f == 9
                                  _total_amnt = _total_amnt + 9
                                else  
                                  _total_amnt = _total_amnt + 6
                                end 
                              end
                            end 
                          else
                            _total_amnt = _total_amnt + tc[:ammount].to_f  
                          end
                          i += 1

                        end
                        sell_price_without_tax = 0
                        sell_price_without_tax = (params["retail_price_#{pos}"].to_f * 100)/(_total_amnt.to_f + 100)
                        if AppConfiguration.get_config_value('uniqe_stock_for_color_size') == 'enabled'
                          # lot = Lot.find_by_menu_product_id_and_sku(mp.id,sku)
                          if _stock.batch_no.present?
                            lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_batch_no_and_mode_and_store_id(_pom.product_id,sku,_stock.expiry_date,sell_price_without_tax,_stock.batch_no,0,@store.id)
                          else
                            lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_mode_and_store_id(_pom.product_id,sku,_stock.expiry_date,sell_price_without_tax,0,@store.id)
                          end 
                          if lot.present? && lot.mode == 0
                            stock_qty = lot.stock_qty + _stock.available_stock.to_f
                            lot.update_attributes(:stock_qty => stock_qty)
                          else 
                            Lot.save_lot(nil,0,sell_price_without_tax,sku,_stock.available_stock,_pom.product_id,expiry_date,_stock.id,params["pro_price_#{pos}"],params["pro_mrp_#{pos}"],nil,color_name,size_name,size_id,color_id,params["description_#{pos}"],params["batch_no_#{pos}"],params["retail_price_#{pos}"].to_f,@store.id,up.id)
                          end 
                        else
                          if _stock.batch_no.present?
                            lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_batch_no_and_mode_and_store_id(_pom.product_id,sku,_stock.expiry_date,sell_price_without_tax,_stock.batch_no,0,@store.id)
                          else
                            lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_mode_and_store_id(_pom.product_id,sku,_stock.expiry_date,sell_price_without_tax,0,@store.id)
                          end 
                          if lot.present? && lot.mode == 0
                            stock_qty = lot.stock_qty + _stock.available_stock.to_f
                            lot.update_attributes(:stock_qty => stock_qty)
                          else 
                            Lot.save_lot(nil,0,sell_price_without_tax,sku,_stock.available_stock,_pom.product_id,expiry_date,_stock.id,params["pro_price_#{pos}"],params["pro_mrp_#{pos}"],nil,color_name,size_name,size_id,color_id,params["description_#{pos}"],params["batch_no_#{pos}"],params["retail_price_#{pos}"].to_f,@store.id,up.id)
                          end 
                        end   
                      end 
                    end 
                  end
                end
              else
                if AppConfiguration.get_config_value("price_for_color_size") == "enabled"
                  _size = Size.find(params["size_#{pos}"]) if params["size_#{pos}"].present?
                  _color = Color.find(params["color_name_#{pos}"]) if params["color_name_#{pos}"].present?
                  _size_id = _size.present? ? _size.id : nil
                  _color_id = _color.present? ? _color.id : nil
                  _size_name = _size.present? ? _size.name : nil
                  _color_name = _color.present? ? _color.name : nil
                  _stock = Stock.save_stock(_pom.product_id,@store.id,params["pro_price_wt_#{pos}"],item_basic_qty,@stock_purchase.id,"stock_purchase",item_basic_qty,0,params["expiry_date_#{pos}"],sku,_mfg_date,params["model_number_#{pos}"],_size_name,_color_name,params["retail_price_#{pos}"],_color_id,_size_id,params["batch_no_#{pos}"],params["free_quantity_#{pos}"],'',params["p_gender_#{pos}"])
                  # _sku = "#{_stock[:product_id]}""#{_color_id}""#{_size_id}" 
                  # sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"].strip : format('%010d', _sku)
                  if AppConfiguration.get_config_value('sku_algorithm') == 'enabled'
                    sku = ''
                    sku = "#{sku}""#{AppConfiguration.get_config('sku_prefix_limit')}" if AppConfiguration.get_config_value('sku_prefix') == 'enabled' 
                    sku = "#{sku}#{_stock.p_gender}#{_stock.product.category.code}#{_stock.product.brand_code}" if AppConfiguration.get_config_value('category_code') == 'enabled'
                    sku = "#{sku}#{_stock.stock_transaction.purchase_order.vendor.code}" if AppConfiguration.get_config_value('vendor_code') == 'enabled'
                    sku = "#{sku}#{_stock.color.code}" if AppConfiguration.get_config_value('color_code') == 'enabled' and _stock.color.present?
                    sku = "#{sku}#{_stock.size.code}" if AppConfiguration.get_config_value('size_code') == 'enabled' and _stock.size.present?
                    sku = "#{sku}#{_stock.product.p_code}" if AppConfiguration.get_config_value('product_serial') == 'enabled'
                  else
                    _sku = "#{_stock[:product_id]}""#{_color_id}""#{_size_id}" 
                    sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"].strip : format('%010d', _sku)
                  end
                else
                  _stock = Stock.save_stock(_pom.product_id,@store.id,params["pro_price_wt_#{pos}"],item_basic_qty,@stock_purchase.id,"stock_purchase",item_basic_qty,0,params["expiry_date_#{pos}"],sku,_mfg_date,params["model_number_#{pos}"],params["size_#{pos}"],params["color_name_#{pos}"],params["retail_price_#{pos}"],nil,nil,params["batch_no_#{pos}"],params["free_quantity_#{pos}"],'',params["p_gender_#{pos}"])
                  if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
                    # if AppConfiguration.get_config_value('uniqe_sku_for_stock') == 'enabled'
                    #   sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"].strip : format('%010d', _stock.id)
                    # else   
                    #   sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"].strip : format('%010d', _pom.product_id) 
                    # end
                    if AppConfiguration.get_config_value('uniqe_sku_for_stock') == 'enabled' 
                      sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"].strip : format('%010d', _stock.id)
                    elsif AppConfiguration.get_config_value('uniqe_stock_for_color_size') == 'enabled'
                      _sku = "#{_pom.product_id}""#{color_id}""#{size_id}"
                      sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"].strip : format('%010d', _sku)
                    elsif AppConfiguration.get_config_value('sku_algorithm') == 'enabled'
                      sku = ''
                      sku = "#{sku}""#{AppConfiguration.get_config('sku_prefix_limit')}" if AppConfiguration.get_config_value('sku_prefix') == 'enabled' 
                      sku = "#{sku}#{_stock.p_gender}#{_stock.product.category.code}#{_stock.product.brand_code}" if AppConfiguration.get_config_value('category_code') == 'enabled'
                      sku = "#{sku}#{_stock.stock_transaction.purchase_order.vendor.code}" if AppConfiguration.get_config_value('vendor_code') == 'enabled'
                      sku = "#{sku}#{_stock.color.code}" if AppConfiguration.get_config_value('color_code') == 'enabled' and _stock.color.present?
                      sku = "#{sku}#{_stock.size.code}" if AppConfiguration.get_config_value('size_code') == 'enabled' and _stock.size.present?
                      sku = "#{sku}#{_stock.product.p_code}" if AppConfiguration.get_config_value('product_serial') == 'enabled'
                    else
                      _sku = "#{_stock[:product_id]}""#{_color_id}""#{_size_id}" 
                      sku = params["pro_sku_#{pos}"].present? ? params["pro_sku_#{pos}"].strip : format('%010d', _sku)
                    end 
                  end  
                end  
                _stock.update_column(:sku, sku)
                _product.update_attribute(:hsn_code, params["pro_hsn_code_#{pos}"])
                params["input_quantity_#{pos}"].map{|iq| SecondaryStock.credit(_stock, iq, params["input_quantity_#{pos}_#{iq}"])} if params["input_quantity_#{pos}"].present?
                params["tax_class_#{_pom.product_id}"].map{|tc| StockTax.add_stock_tax(_stock.id, tc, params["tax_class_#{tc}_#{_pom.product_id}"], params["tax-on-#{_pom.product_id}-#{tc}"])} if params["tax_class_#{_pom.product_id}"].present?
                _product_tax = params["tax_class_#{pos}"].present? ? params["tax_class_#{pos}"].map{ |e| params["tax_class_#{e}_#{pos}"].to_f }.reduce(0, :+) : 0  
                StockPrice.add_stock_price(_stock.id, params["pro_price_#{pos}"], params["pro_mrp_#{pos}"], _pom.product_id, params["pro_pwot_#{pos}"], _product_tax, params["pro_additional_cost_#{pos}"], params["pro_price_wt_#{pos}"], params["addon_remarks_#{pos}"],params["pro_dicount_#{pos}"],params["sales_percentage_#{pos}"],params["retail_price_#{pos}"],params["margin_on_mrp_#{pos}"],params["purchase_cost_#{pos}"],params["volume_discount_#{pos}"],params["scheme_discount_#{pos}"],params["scheme_discount_by_amount_#{pos}"],params["discount_on_mrp_#{pos}"])
                if AppConfiguration.get_config_value('Percentage_applied_on_lending_price') == 'enabled'
                  menu_cards = MenuCard.set_unit(current_user.unit_id)
                  menu_cards.each do |mc|
                    if MenuProduct.by_menu_card(mc.id).set_product(_pom.product_id).present?
                      mp = MenuProduct.by_menu_card(mc.id).set_product(_pom.product_id).first
                      mp.update_attributes(:sell_price_without_tax=> params["pro_mrp_#{pos}"], :sell_price=> (params["pro_mrp_#{pos}"].to_f + (params["pro_mrp_#{pos}"].to_f * mp.tax_group.total_amnt.to_f / 100)).round)
                    end 
                  end   
                end
                if AppConfiguration.get_config_value('retail_menu') == 'enabled'
                  if UnitProduct.by_unit(current_user.unit_id).by_product(_pom.product_id).present?
                    up = UnitProduct.by_unit(current_user.unit_id).by_product(_pom.product_id).first
                    _total_amnt = 0
                    i = 1
                    @tax_array = up.tax_group.tax_classes
                    @tax_array.sort { |a, b|  a.ammount <=> b.ammount }
                    @tax_array.each do |tc|
                      if tc.tax_type == 'variable'
                        if params["retail_price_#{pos}"].to_f <= _limit_vtax
                          if i == 1
                            _total_amnt = _total_amnt + 2.5    
                          elsif i == 2
                            _total_amnt = _total_amnt + 2.5
                          end
                        else
                          if i == 3
                            if tc.ammount.to_f == 9.00 || tc.ammount.to_f == 9
                              _total_amnt = _total_amnt + 9
                            else  
                              _total_amnt = _total_amnt + 6
                            end  
                          elsif i == 4
                            if tc.ammount.to_f == 9.00 || tc.ammount.to_f == 9
                              _total_amnt = _total_amnt + 9
                            else  
                              _total_amnt = _total_amnt + 6
                            end 
                          end
                        end 
                      else
                        _total_amnt = _total_amnt + tc[:ammount].to_f  
                      end
                      i += 1
                    end
                    sell_price_without_tax = 0
                    sell_price_without_tax = (params["retail_price_#{pos}"].to_f * 100)/(_total_amnt.to_f + 100)
                    
                    if AppConfiguration.get_config_value('uniqe_stock_for_color_size') == 'enabled'
                      if _stock.batch_no.present?
                        lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_batch_no_and_mode_and_store_id(_pom.product_id,sku,_stock.expiry_date,sell_price_without_tax,_stock.batch_no,0,@store.id)
                      else
                        lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_mode_and_store_id(_pom.product_id,sku,_stock.expiry_date,sell_price_without_tax,0,@store.id)
                      end    
                      if lot.present? && lot.mode == 0
                        stock_qty = lot.stock_qty + _stock.available_stock.to_f
                        lot.update_attributes(:stock_qty => stock_qty)
                      else 
                        Lot.save_lot(nil,0,sell_price_without_tax,sku,_stock.available_stock,_pom.product_id,expiry_date,_stock.id,params["pro_price_#{pos}"],params["pro_mrp_#{pos}"],nil,_color_name,_size_name,_size_id,_color_id,params["description_#{pos}"],params["batch_no_#{pos}"],params["retail_price_#{pos}"].to_f,@store.id,up.id)
                      end 
                    else
                      if _stock.batch_no.present?
                        lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_batch_no_and_mode_and_store_id(_pom.product_id,sku,_stock.expiry_date,sell_price_without_tax,_stock.batch_no,0,@store.id)
                      else
                        lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_mode_and_store_id(_pom.product_id,sku,_stock.expiry_date,sell_price_without_tax,0,@store.id)
                      end
                      if lot.present? && lot.mode == 0
                        stock_qty = lot.stock_qty + _stock.available_stock.to_f
                        lot.update_attributes(:stock_qty => stock_qty)
                      else 
                        Lot.save_lot(nil,0,sell_price_without_tax,sku,_stock.available_stock,_pom.product_id,expiry_date,_stock.id,params["pro_price_#{pos}"],params["pro_mrp_#{pos}"],nil,nil,nil,nil,nil,params["description_#{pos}"],params["batch_no_#{pos}"],params["retail_price_#{pos}"].to_f,@store.id,up.id) 
                      end 
                    end   
                  end 
                end  
              end  
            end
            
            if AppConfiguration.get_config_value('Percentage_applied_on_lending_price') == 'enabled'
              menu_cards = MenuCard.set_unit(current_user.unit_id)
              menu_cards.each do |mc|
                if MenuProduct.by_menu_card(mc.id).set_product(_pom.product_id).present?
                  mp = MenuProduct.by_menu_card(mc.id).set_product(_pom.product_id).first
                  mp.update_attributes(:sell_price_without_tax=> params["pro_mrp_#{pos}"], :sell_price=> (params["pro_mrp_#{pos}"].to_f + (params["pro_mrp_#{pos}"].to_f * mp.tax_group.total_amnt.to_f / 100)).round)
                end 
              end   
            end
             
          end
          StockPurchase.update_purchase_status(@stock_purchase) # Update purchase status
          @stock_purchase.update_attributes( :total_amount => @stock_purchase.stocks.sum(:price).round(2), :remarks => params[:remarks], :invoice_amount => params[:invoice_amount], :invoice_no => params[:invoice_no], :grn_no => params[:grn_no], :travelling_cost => params[:travelling_cost], :discount_on_po => params[:discount_on_po], :invoice_date => params[:invoice_date] )
          StockPurchase.update_payment_status(@stock_purchase) # Update purchase status
          # Upload invoice image
          if params[:invoice_image].present?
            file_name = (Time.now.to_i).to_s+"-"+params[:invoice_image].original_filename
            File.open(Rails.root.join('public','uploads','attachments',file_name),'wb') do |file| 
              file.write(params[:invoice_image].read)
            end
            @stock_purchase.update_attribute(:attachment, file_name)
          end
          if params[:payment_mode].present?
            paid_amount = 0
            payment= StockPurchasePayment.new(:payment_mode =>params[:payment_mode],:payment_amount =>params[:paid_amount], :stock_purchase_id =>params[:id], :vendor_id=> @stock_purchase.purchase_order.vendor_id, :details => params[:details])
            payment.save
            paid_amount = @stock_purchase.paid_amount if @stock_purchase.paid_amount.present?
            paid_amount = paid_amount + params[:paid_amount].to_f
            @stock_purchase.update_attribute(:paid_amount, paid_amount)
            StockPurchase.update_payment_status(@stock_purchase)
          end
        end
      end
      redirect_to store_stock_purchase_path(@store,@stock_purchase), notice: 'PO items has been successfully added to stock.'  
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to store_stock_purchase_path(@store,@stock_purchase), alert: e.message.to_s
    end
  end

  
  def barcodes
    @stock_purchase = StockPurchase.find(params[:id])
  end

  def import
    begin
      ActiveRecord::Base.transaction do
        total_rows = 0
        error_message = []
        if params[:file].present?
          file_name = params[:file].tempfile.to_path.to_s
          file_type = params[:file].original_filename.split('.')
          raise "File format should be csv." unless file_type[1] == "csv"
          # if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled' and AppConfiguration.get_config_value('retail_menu') == 'enabled'
          #   if current_user.unit.unittype.unit_type_name.downcase == "outlet"
          #     raise "Atleast one Menu card should be selected" unless params[:menu_card_ids].present?
          #     menu_card_ids = params[:menu_card_ids]
          #     menu_cards = MenuCard.by_menu_card_in(menu_card_ids)
          #   else
          #     menu_cards = MenuCard.set_unit(current_user.unit_id)  
          #   end  
          # else
          #   menu_cards = MenuCard.set_unit(current_user.unit_id).active
          # end          
          # total_rows = CSV.read(params[:file].path).count
          total_rows = CSV.foreach(params[:file].path, headers: true).count
          if total_rows < 501
            CSV.foreach(params[:file].path, headers: true) do |csv_row|
              # if params[:menu_card_ids].present?
              #   _errors = validate_catalog_product(csv_row,params[:menu_card_ids])
              # else
              #   _errors = validate_catalog_product(csv_row,nil)
              # end
              _errors = validate_catalog_product(csv_row)
              if !_errors.blank?
                error_message.push _errors
              end
            end
          else
            error_message.push "No. of rows should be less than 500."
          end
        end
        if !error_message.blank?
          redirect_to :back, alert: error_message.join(", ")
        else
          StockPurchase.import(params[:file],params[:store_id],params[:stock_transaction_id],params[:stock_transaction_type],current_user.unit_id,total_rows)
          redirect_to :back, notice: 'Stock was successfully imported.'
        end
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :back
    end
  end

  def edit_stock_purchase
    @stock_purchase = StockPurchase.find(params[:id])
  end
  
  def cancel_stock_purchase
    @stock_purchase = StockPurchase.find(params[:stock_purchase_id])
    _stocks = @stock_purchase.stocks.available
    if params[:product_id].present?
      _product_id = params[:product_id]
      _stocks = _stocks.get_product(params[:product_id])
      stock_cancel_qty = params["stock_cancel_qty_#{_product_id}"]
    end
    _stocks.each do |object|
      stock_cancel_qty = object.available_stock unless params[:product_id].present?
      Stock.reduce_product_stock(object.store_id,object.product.id,stock_cancel_qty.to_f,@stock_purchase.id,"stock_purchase")
    end
    _stock_purchase_total_price = @stock_purchase.total_amount
    _cancelled_stocks = @stock_purchase.stocks.type_debit
    _cancelled_stocks_product_ids = _cancelled_stocks.uniq.pluck(:product_id)
    _remaining_product_stocks_price = 0
    _cancelled_stocks_product_ids.each do |cancelled_product_id|
      _cancelled_product_stocks_qty = _cancelled_stocks.get_product(cancelled_product_id).sum(:stock_debit)
      _credited_product_stocks = @stock_purchase.stocks.type_credit.get_product(cancelled_product_id)
      _credited_product_stocks_qty = _credited_product_stocks.sum(:stock_credit)
      _credited_product_stocks_price = _credited_product_stocks.sum(:price)
      _remaining_product_stocks_price += ( _credited_product_stocks_price / _credited_product_stocks_qty ) * ( _credited_product_stocks_qty - _cancelled_product_stocks_qty)
    end
    _remaining_total_product_price = @stock_purchase.stocks.type_credit.get_product_not_in(_cancelled_stocks_product_ids).sum(:price)
    _total_sp_price = _remaining_total_product_price + _remaining_product_stocks_price
    @stock_purchase.update_column(:total_amount, _total_sp_price)
    respond_to do |format|
      new_status = params[:product_id].present? ? 'partially_cancelled' : 'cancelled'
      @stock_purchase.update_column(:cancellation_status, new_status)

      # _mail_send = AppConfiguration.get_config_value('vendor_email')
      # VendorMailer.vendor_email(@stock_purchase.purchase_order,currency,@current_user,@stock_purchase).deliver if _mail_send == "enabled"

      format.json { render json: @stock_purchase }
      format.js
    end
  end

  private

  def set_module_details
    @module_id = "inventory"
    @module_title = "Inventory"
  end

  def validate_catalog_product(_header)
    _product = Product.find_by_name(_header["Product"])
    _errors = []
    # raise "Product #{_header["Product"]} does not exist." unless _product.present?
    _errors.push "Product #{_header["Product"]} does not exist." unless _product.present?
    _exp_date = ""
    _mfg_date = ""
    if _product.present?
      if _header["Expiry Date"].present?
        _exp_date = Date.parse(_header["Expiry Date"]) rescue nil
        if _exp_date == nil
          _errors.push "Expiry date for product #{_header["Product"]} is invalid."
        else
          if _exp_date < Date.today
            _errors.push "Expiry date is backdated for product #{_header["Product"]}"
          end
        end
      end
      if _header["Mfg Date"].present?
        _mfg_date = Date.parse(_header["Mfg Date"]) rescue nil
        _errors.push "Mfg date for product #{_header["Product"]} is invalid." if _mfg_date == nil
      end
      if _header["MRP"].present? && _header["Sale price with tax"].present?
        if _header["MRP"].to_f < _header["Sale price with tax"].to_f
          _errors.push "Mrp should be greater than Sale price for product #{_header["Product"]}"
        end
      end
      # if current_user.unit.unittype.unit_type_name.downcase == "outlet"
      #   _active_menu_cards = current_user.unit.menu_cards
      #   if _active_menu_cards.present?
      #     _active_menu_cards.each do |_menu_card|
      #       _menu_product = MenuProduct.by_menu_card(_menu_card.id).set_product(_product.id)
      #       if !_menu_product.present?
      #         _errors.push "Product #{_header["Product"]} does not belongs to Menu Card #{_menu_card.name}"
      #       end
      #     end
      #   else
      #     _errors.push "No Menu Card has been found."
      #   end
      # end
      # if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled' and AppConfiguration.get_config_value('retail_menu') == 'enabled'
      #   if current_user.unit.unittype.unit_type_name.downcase == "outlet"
      #     if _menu_card_ids == nil
      #       _errors.push "Atleast one Menu card should be selected."
      #     else
      #       menu_cards = MenuCard.by_menu_card_in(_menu_card_ids)
      #     end
      #   else
      #     menu_cards = MenuCard.set_unit(current_user.unit_id).active
      #   end  
      # else
      #   menu_cards = MenuCard.set_unit(current_user.unit_id).active
      # end
      # if menu_cards.present?
      #   menu_cards.each do |_menu_card|
      #     _menu_product = MenuProduct.by_menu_card(_menu_card.id).set_product(_product.id)
      #     if !_menu_product.present?
      #       _errors.push "Product #{_header["Product"]} does not belongs to Menu Card #{_menu_card.name}"
      #     end
      #   end
      # else
      #   _errors.push "No Menu Card has been found."
      # end
      if !_product.unit_products.by_unit(current_user.unit_id).present?
        _errors.push "Product #{_header["Product"]} does not belongs to #{current_user.unit.unit_name}"
      end
    end
    return _errors
  end

  def set_module_details
    @module_id = "inventory"
    @module_title = "Inventory"
  end

  def set_layout
    if action_name == 'barcodes'
      false
    else
      "material"
    end
  end

  def validate_csv_data(_header,po_products,csv_product_array)
    _product = Product.find_by_name(_header[:product_name])
    puts _product
    raise "Product #{_header[:product_name]} does not exist." unless _product.present?
    raise "Product #{_header[:product_name]} does not exist in purchase order, remove it from the csv and try again." unless po_products.include?(_product.id)
    #Column data validation
    if _product.business_type == "by_mrp"
      raise "Product #{_header[:product_name]} does not have COG or QUANTITY or MRP column in the uploaded csv." unless _header[:cog].present? and _header[:quantity].present? and _header[:mrp].present?  
    elsif _product.business_type == "by_weight"
      raise "Product #{_header[:product_name]} does not have COG or QUANTITY or WASTAGE or WEIGHT or PRODUCT_UNIT_ID or MAKING_COST column in the uploaded csv." unless _header[:cog].present? and _header[:quantity].present? and _header[:wastage].present? and _header[:weight].present? and _header[:product_unit_id].present? and _header[:making_cost].present?
    elsif _product.business_type == "by_bulk_weight"
      raise "Product #{_header[:product_name]} does not have TOTAL_WASTAGE or WEIGHT or PRODUCT_UNIT_ID or TOTAL_MAKING_COST, TOTAL_COG column in the uploaded csv." unless _header[:total_cog].present? and _header[:total_wastage].present? and _header[:weight].present? and _header[:product_unit_id].present? and _header[:total_making_cost].present?
    end
    # Building array for products present in excel sheet
    if csv_product_array.present?
      csv_product_array.push(_product.id) unless csv_product_array.include?(_product.id)
    else
      csv_product_array.push(_product.id)
    end
    return csv_product_array
  end

end
