class SimosController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  layout "material"
  def new
    @categories = Category.all
    @simo = Simo.new
    @store = Store.find(params[:store_id])
    filter_product = SimoInputProduct.filter_product(params[:filter]) if params[:filter].present?
    product_scope = Product.conjugated_product
    product_scope = product_scope.filter_by_product_category(params[:product_category]) if params[:product_category].present?
    product_scope = product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    smart_listing_create :products, product_scope, partial: "products/product_simo_smartlist", default_sort: {id: "desc"}
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  def create
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        @simo = Simo.new(params[:simo])
        @simo[:status]= "initial_state"
        @store = Store.find(params[:simo][:store_id])
        raise 'No products selected for new simo input product.' if params[:checked_raw].nil?
        @simo.save
        params[:checked_raw].each do |product|
          _price = Stock.estimate_stock_consumption_price(@simo.store_id, product, params["quantity#{product}"])
          _product = Product.find(product)
          _input_product = SimoInputProduct.new()
          _input_product.product_id = product
          _input_product.simo_id = @simo.id
          _input_product.quantity = params["quantity#{product}"]
          _input_product.conjugated_id = _product.conjugated_unit_id
          _input_product.price = _price
          _input_product.save
        end
        #@simo.update_attributes(:status => "processed")
        redirect_to store_simo_path(@store,@simo), notice: 'Simo initiated.'
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_store_simo_path(@store), alert: e.message
    end
  end  

  def update
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        @simo = Simo.find(params[:simo][:simo_id])
        @store = Store.find(params[:simo][:store_id])
        puts @simo.status
        raise 'No products selected for new simo input product.' if params[:checked_raw].nil?
          if @simo.status == 'initial_state'
            prev = SimoOutputProductTemplate.where('input_product_id =?', @simo.simo_input_product.product_id)
            prev.destroy_all if prev.present?
            params[:checked_raw].each do |product|
              _product =Product.find(product)
              _output_product=SimoOutputProduct.new()
              _output_product.basic_unit_id =_product.basic_unit_id
              _output_product.product_id = product
              _output_product.expected_quantity = params["expected_quantity#{product}"]
              _output_product.simo_id = @simo.id
              _output_product.simo_input_product_id = @simo.simo_input_product.id
              _output_product.price = params["price#{product}"]
              _output_product.save
              SimoOutputProductTemplate.save_template(@simo.simo_input_product.product_id,product)
            end
            @simo.update_attributes(:status => "processed")
          elsif @simo.status == 'processed'
            params[:checked_raw].each do |product|
              _output_product=SimoOutputProduct.find(product)
              puts _output_product.inspect
              puts params["actual_quantity#{product}"]
              _output_product.update_attributes(:actual_quantity =>params["actual_quantity#{product}"] ,:total_weight => params["weight#{product}"])
            end 
            @simo.update_attributes(:status => "finished")
            @simo.update_attributes(:isStockAdded => 0)
          elsif @simo.status == 'finished'
            if @simo.isStockAdded == 0
              params[:checked_raw].each do |p_id|
                # Stock.save_stock(spm.product_id,_stock_production.store_id,spm.price,spm.production_quantity,_stock_production.id,'stock_production',spm.production_quantity,0,nil,nil,nil) 
                sop = SimoOutputProduct.find_by_simo_id_and_product_id(@simo.id,p_id)
                sop_price = sop.price
                save_stock = Stock.save_stock(p_id,@simo.store_id,"#{sop_price}",params["actual_quantity#{p_id}"],@simo.simo_input_product.id,"simo_input_product",params["actual_quantity#{p_id}"],0,params["expiry_date_#{p_id}"],params["sku_#{p_id}"],params["mfg_date_#{p_id}"],params["model_number_#{p_id}"],params["size_#{p_id}"],params["color_#{p_id}"],nil,nil,nil,params["batch_no_#{p_id}"],nil)
                if save_stock
                  if AppConfiguration.get_config_value('uniqe_sku_for_stock') == 'enabled'
                    sku = params["sku_#{p_id}"].present? ? params["sku_#{p_id}"] : format('%08d', save_stock.id)
                  else    
                    sku = params["sku_#{p_id}"].present? ? params["sku_#{p_id}"] : format('%08d', save_stock[:product_id]) 
                  end
                  save_stock.update_column(:sku, sku)
                  StockPrice.add_stock_price(save_stock.id, nil, params["mrp_#{p_id}"], save_stock[:product_id], nil, nil, nil, 100, "",nil,nil,nil)
                end
              end
              @simo.update_attributes(:isStockAdded => 1)
            end
          end
        if @simo.isStockAdded == 0 or @simo.isStockAdded == 1
          redirect_to store_simo_path(@store,@simo), notice: 'SIMO Process updated successfully. Now add to stock.'
        else
          redirect_to store_path(@store), notice: 'SIMO Process updated successfully.'
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_store_simo_path(@store), alert: e.message
    end      
  end

  def show
    @categories = Category.all
    @simo = Simo.find(params[:id])
    @store = Store.find(params[:store_id])
    @output_products = SimoOutputProductTemplate.input_product(@simo.simo_input_product.product_id)
    @purchase_order = PurchaseOrder.new
    #product_scope = Product.not_conjugated_product
    @site_title = AppConfiguration.get_config_value('site_title')
    product_scope = Product.order('id desc')
    product_scope = product_scope.filter_by_product_type(params[:product_type]) if params[:product_type].present?
    product_scope = product_scope.filter_by_product_category(params[:product_category]) if params[:product_category].present?
    product_scope = product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    smart_listing_create :products, product_scope,  partial: "products/product_simo_output_smartlist", default_sort: {id: "desc"}
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  def toggle_trash
    @simo = Simo.find(params[:id])
    @store = Store.find(params[:store_id])
    if @simo.update_attributes(:status => "Istrashed") 
      Stock.save_stock(@simo.simo_input_product.product_id,@simo.store_id,@simo.simo_input_product.price,@simo.simo_input_product.quantity,@simo.simo_input_product.id,"simo_input_product",@simo.simo_input_product.quantity,0,nil,nil,nil)
    end  
    respond_to do |format|
      format.html { redirect_to  kitchen_store_store_path(@store), notice: 'SIMO process cancelled successfully.' }
      format.json { head :no_content }
    end
  end 
end


