include ApplicationHelper
class PurchaseOrdersController < ApplicationController
  #Cancan Authorization
  load_and_authorize_resource :except => [ :send_purchase_order ]

  #Including required libraries
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  layout "material"

  #Controller filters
  before_filter :set_module_details
  before_filter :get_current_user, only: [:new, :create]

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
    @store = Store.find(params[:store_id])
    @purchase_orders = PurchaseOrder.where(:store_id => @store.id)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @purchase_orders }
    end
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show
    @store = Store.find(params[:store_id])
    @purchase_order = PurchaseOrder.find(params[:id])
    @approvals = @purchase_order.approvals
    # if @approvals.present?
    _purchase_order_json = @purchase_order.to_json(:include => {:approvals => {:include => [:role, :user] }, :purchase_order_metum => {:include => [:product, :product_unit,:product_transaction_unit, :purchase_order_metum_descrptions => {:include => [:color, :size] }]}} )
    # else
    #   _purchase_order_json = @purchase_order.to_json(:include => {:purchase_order_metum => {:include => [:product, :product_unit,:product_transaction_unit, :purchase_order_metum_descrptions => {:include => [:color, :size] }]}})
    # end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json:_purchase_order_json }
    end
  end

  # GET /purchase_orders/new
  # GET /purchase_orders/new.json
  def new
    @store = Store.find(params[:store_id])
    @purchase_order = PurchaseOrder.new
    @purchase_order_metum = StoreRequisitionMetum.new
    #@vendors = Vendor.where(:unit_id => @current_user.unit_id)
    @categories = Category.all
    @vendor = Vendor.find(params[:vendor] || params[:vendor_id])
    @products = @vendor.products.where(:business_type=> params[:business_type])
    product_scope = @vendor.products.where(:business_type=> params[:business_type])
    product_scope = product_scope.filter_by_product_type(params[:product_type]) if params[:product_type].present?
    product_scope = product_scope.filter_by_product_category(params[:product_category]) if params[:product_category].present?
    product_scope = product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    product_scope = product_scope.filter_by_product_id(params[:product_id_filter]) if params[:product_id_filter].present?
    smart_listing_create :products, product_scope, partial: "products/purchase_order_input_smartlist", default_sort: {id: "desc"}
    if AppConfiguration.get_config_value('smart_po') == 'enabled' && AppConfiguration.get_config_value('on_behalf_po') == 'enabled'
      smart_listing_create :on_behalf_smart_po_products, product_scope, partial: "purchase_orders/on_behalf_smart_po_input_smartlist", default_sort: {id: "desc"}
      if @current_user.unit.unittype.unit_type_name.humanize == "Distribution center"
        unit_ids = []
        @current_user.unit.children.map { |e| unit_ids.push e.id } if @current_user.unit.children.present?
        unit_ids << @current_user.unit.id
        _units = Unit.set_id_in(unit_ids)
        smart_listing_create :child_outlets, _units, partial: "purchase_orders/child_outlets_smartlist", default_sort: {id: "asc"}, :page_sizes => [8]
      end
    end

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @purchase_order }
    end
  end

  # GET /purchase_orders/1/edit
  def edit
    @store = Store.find(params[:store_id])
    @purchase_order = PurchaseOrder.find(params[:id])
    @purchase_order_metum = @purchase_order.purchase_order_metum.not_cancelled
  end

  # POST /purchase_orders
  # POST /purchase_orders.json
  def create
    puts params
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        if AppConfiguration.get_config_value('smart_po') != 'enabled' && AppConfiguration.get_config_value('on_behalf_po') != 'enabled'
          _purchase_order = PurchaseOrder.new(params[:purchase_order])
          @store = Store.find(_purchase_order[:store_id])
          raise 'No products selected for new purchase order.' unless !params[:checked_raw].blank?
          _purchase_order[:user_id]=current_user.id
          _purchase_order[:unit_id]=current_user.unit_id
          _purchase_order[:recurring]=0
          _purchase_order[:purchase_order_code]="PO"+(Time.now.to_i).to_s+"#{rand(1000)}"
          _purchase_order.save
          if AppConfiguration.get_config_value("price_for_color_size") == "enabled"
            params[:checked_raw].each do |c|
              if params[:purchase_order][:business_type]=='by_catalog'
                _vendor_product = VendorProduct.find(params["vendor_product_id#{c}"])
                vendor_price =  params["price#{c}"]
                if params["transaction_unit_#{c}"].present?
                  _multiplier = ProductTransactionUnit.find(params["transaction_unit_#{c}"]).basic_unit_multiplier
                  vendor_price =  (params["price#{c}"].to_f/_multiplier).round(2)
                end
                _vendor_product.update_attributes(:price=> vendor_price)
              end  
              if params["checked_raw_single_product"].present?
                params["checked_raw_single_product"].each do |color_size_product|
                  _color_size_split = color_size_product.split('_')
                  _product_id = _color_size_split[0]
                  _color_id = _color_size_split[1]
                  _size_id = _color_size_split[2]
                  if _product_id == c
                    _purchase_order_metum = PurchaseOrderMetum.new(params[:purchase_order_metum])
                    _purchase_order_metum[:product_id] = c
                    _purchase_order_metum[:price_per_unit] = params["price#{c}"]
                    if params["unit#{c}"].to_i > 0
                      unit = ProductUnit.find(params["unit#{c}"].to_i)
                      _quantity = params["quantity#{c}"].to_f * ProductTransactionUnit.find(params["transaction_unit_#{c}"]).basic_unit_multiplier
                      _purchase_order_metum[:product_amount] = _quantity
                      _purchase_order_metum[:secondary_amount] = params["quantity#{c}"]
                      _purchase_order_metum[:secondary_product_unit_id] = unit.id
                      _purchase_order_metum[:transaction_unit_id] = params["transaction_unit_#{c}"]
                      
                      if _size_id.to_i != 0
                        _purchase_order_metum[:size_id] = _size_id
                      end 
                      if _color_id.to_i != 0 
                        _purchase_order_metum[:color_id] = _color_id
                      end
                    else
                      _purchase_order_metum[:product_amount] = params["single_item_quantity#{_product_id}_#{_color_id}_#{_size_id}"]
                      if _size_id.to_i != 0
                        _purchase_order_metum[:size_id] = _size_id
                      end 
                      if _color_id.to_i != 0 
                        _purchase_order_metum[:color_id] = _color_id
                      end
                    end
                    _purchase_order.purchase_order_metum << _purchase_order_metum
                  end  
                end  
              else
                _purchase_order_metum = PurchaseOrderMetum.new(params[:purchase_order_metum])
                _purchase_order_metum[:product_id] = c
                _purchase_order_metum[:price_per_unit] = params["price#{c}"]
                if params["unit#{c}"].to_i > 0
                  unit = ProductUnit.find(params["unit#{c}"].to_i)
                  _quantity = params["quantity#{c}"].to_f * ProductTransactionUnit.find(params["transaction_unit_#{c}"]).basic_unit_multiplier
                  _purchase_order_metum[:product_amount] = _quantity
                  _purchase_order_metum[:secondary_amount] = params["quantity#{c}"]
                  _purchase_order_metum[:secondary_product_unit_id] = unit.id
                  _purchase_order_metum[:transaction_unit_id] = params["transaction_unit_#{c}"]
                  
                else
                  _purchase_order_metum[:product_amount] = params["quantity#{c}"]
                end
                _purchase_order.purchase_order_metum << _purchase_order_metum
              end    
            end
          else
            params[:checked_raw].each do |c|
              if params[:purchase_order][:business_type]=='by_catalog'
                _vendor_product = VendorProduct.find(params["vendor_product_id#{c}"])
                vendor_price =  params["price#{c}"]
                if params["transaction_unit_#{c}"].present?
                  _multiplier = ProductTransactionUnit.find(params["transaction_unit_#{c}"]).basic_unit_multiplier
                  vendor_price =  (params["price#{c}"].to_f/_multiplier).round(2)
                end
                _vendor_product.update_attributes(:price=> vendor_price)
              end  

              _purchase_order_metum = PurchaseOrderMetum.new(params[:purchase_order_metum])
              _purchase_order_metum[:product_id] = c
              _purchase_order_metum[:price_per_unit] = params["price#{c}"]
              if params["unit#{c}"].to_i > 0
                unit = ProductUnit.find(params["unit#{c}"].to_i)
                _quantity = params["quantity#{c}"].to_f * ProductTransactionUnit.find(params["transaction_unit_#{c}"]).basic_unit_multiplier
                _purchase_order_metum[:product_amount] = _quantity
                _purchase_order_metum[:secondary_amount] = params["quantity#{c}"]
                _purchase_order_metum[:secondary_product_unit_id] = unit.id
                _purchase_order_metum[:transaction_unit_id] = params["transaction_unit_#{c}"]
                
              else
                _purchase_order_metum[:product_amount] = params["quantity#{c}"]

              end
              _purchase_order.purchase_order_metum << _purchase_order_metum

              if params["checked_raw_single_product"].present?
                params["checked_raw_single_product"].each do |color_size_product|
                  _color_size_split = color_size_product.split('_')
                  _product_id = _color_size_split[0]
                  _color_id = _color_size_split[1]
                  _size_id = _color_size_split[2]
                  if c == _product_id
                    _purchase_order_metum_descrption = PurchaseOrderMetumDescrption.new()
                    if _size_id.to_i != 0
                      _purchase_order_metum_descrption[:size_id] = _size_id
                    end 
                    if _color_id.to_i != 0 
                      _purchase_order_metum_descrption[:color_id] = _color_id
                    end
                    _purchase_order_metum_descrption[:product_id] = _product_id
                    _purchase_order_metum_descrption[:quantity] = params["single_item_quantity#{_product_id}_#{_color_id}_#{_size_id}"]
                    _purchase_order_metum_descrption[:purchase_order_id] = _purchase_order.id
                    _purchase_order_metum_descrption[:purchase_order_metum_id] = _purchase_order_metum.id
                    _purchase_order_metum_descrption.save
                  end
                end
              end
            end
          end 
          redirect_to store_path(@store), notice: 'Purchase order was successfully created.'
        else
          @store = Store.find(params[:purchase_order][:store_id])
          raise 'No outlets selected for new purchase order.' unless !params[:destination_units].blank?
          raise 'No products selected for new purchase order.' unless !params[:checked_raw].blank?

          _smart_po = SmartPo.new
          _smart_po.name = params[:purchase_order][:name]
          _smart_po.source_unit = current_user.unit_id
          _smart_po.user_id = current_user.id
          _smart_po.store_id = params[:purchase_order][:store_id]
          _smart_po.valid_from = params[:purchase_order][:valid_from]
          _smart_po.valid_till = params[:purchase_order][:valid_till]
          _smart_po.vendor_id = params[:purchase_order][:vendor_id]

          params[:checked_raw].each do |c|
            if params[:purchase_order][:business_type]=='by_catalog'
              _vendor_product = VendorProduct.find(params["vendor_product_id#{c}"])
              vendor_price =  params["price#{c}"]
              if params["transaction_unit_#{c}"].present?
                _multiplier = ProductTransactionUnit.find(params["transaction_unit_#{c}"]).basic_unit_multiplier
                vendor_price =  (params["price#{c}"].to_f/_multiplier).round(2)
              end
             _vendor_product.update_attributes(:price=>params["price#{c}"])
            end
          end
          
          if _smart_po.save
            params[:destination_units].split(',').each do |dest_unit|
              
              _purchase_order = PurchaseOrder.new
              _purchase_order.smart_po_id = _smart_po.id
              _purchase_order.name = params[:purchase_order][:name]
              _purchase_order.user_id = current_user.id
              _purchase_order.store_id = params["store_unit_#{dest_unit}"]
              _purchase_order.unit_id = dest_unit
              _purchase_order.recurring = 0
              _purchase_order.purchase_order_code = "PO"+(Time.now.to_i).to_s+"#{rand(1000)}"
              _purchase_order.vendor_id = params[:purchase_order][:vendor_id]
              _purchase_order.business_type = params[:purchase_order][:business_type]
              _purchase_order.valid_from = params[:purchase_order][:valid_from]
              _purchase_order.valid_till = params[:purchase_order][:valid_till]

              if _purchase_order.save
                
                params[:checked_raw].each do |c|
                  _purchase_order_metum = PurchaseOrderMetum.new
                  _purchase_order_metum.product_id = c
                  if params["unit#{c}"].to_i > 0
                    product_unit = ProductUnit.find(params["unit#{c}"].to_i)
                    _quantity = params["quantity#{c}"].to_f * product_unit.multiplier.to_f
                    _purchase_order_metum.product_amount = _quantity
                    _purchase_order_metum.secondary_amount = params["quantity#{c}"]
                    _purchase_order_metum.secondary_product_unit_id = product_unit.id
                  else
                    _purchase_order_metum.product_amount = params["quantity#{c}"]
                  end
                  _purchase_order.purchase_order_metum << _purchase_order_metum
                  if params["checked_raw_single_product"].present?
                    params["checked_raw_single_product"].each do |color_size_product|
                      _color_size_split = color_size_product.split('_')
                      _product_id = _color_size_split[0]
                      _color_id = _color_size_split[1]
                      _size_id = _color_size_split[2]
                      if c == _product_id
                        _purchase_order_metum_descrption = PurchaseOrderMetumDescrption.new()
                        # if _size_id.to_i != 0
                        #   _purchase_order_metum_descrption[:size_id] = _size_id
                        # end 
                        # if _color_id.to_i != 0 
                        #   _purchase_order_metum_descrption[:color_id] = _color_id
                        # end
                        _purchase_order_metum_descrption[:color_id] = _color_id
                        _purchase_order_metum_descrption[:size_id] = _size_id
                        _purchase_order_metum_descrption[:product_id] = _product_id
                        _purchase_order_metum_descrption[:quantity] = params["single_item_quantity#{_product_id}_#{_color_id}_#{_size_id}"]
                        _purchase_order_metum_descrption[:purchase_order_id] = _purchase_order.id
                        _purchase_order_metum_descrption[:purchase_order_metum_id] = _purchase_order_metum.id
                        _purchase_order_metum_descrption.save
                      end
                    end
                  end
                end

              end
            end
          end
          if _purchase_order.purchase_order_metum
            redirect_to store_purchase_order_steps_path(@store,:smart_po_id => _smart_po.id), notice: 'Purchase Order initiated'
          else
            redirect_to store_path(@store)
          end
        end
      end
      # redirect_to store_path(@store), notice: 'Purchase order was successfully created.'
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_store_purchase_order_path(@store)+"?vendor_id=#{params[:purchase_order][:vendor_id]}&business_type=#{params[:purchase_order][:business_type]}", alert: e.message
    end
  end

  # PUT /purchase_orders/1
  # PUT /purchase_orders/1.json
  def update
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        @store = Store.find(params[:store_id])
        @purchase_order = PurchaseOrder.find(params[:id])
        params[:purchase_orders].each do |pom|
          if pom['action'] == 'new'
            @new_po_meta = PurchaseOrderMetum.new
            @new_po_meta.product_amount = pom['product_amount']
            @new_po_meta.product_id = pom['product_id']
            @new_po_meta.purchase_order_id = params[:id]
            @new_po_meta.price_per_unit = pom['price_per_unit']
            @new_po_meta.save
          elsif pom['action'] == 'update'
            @po_meta = PurchaseOrderMetum.find(pom['meta_id'])
            @po_meta.update_attributes(:product_amount => pom['product_amount'], :price_per_unit => pom['price_per_unit'])
          end
        end
      end
      redirect_to store_path(@store), notice: 'Purchase order is successfully updated.'
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to edit_store_purchase_order_path(@store), alert: e.message
    end

  end

  # DELETE /purchase_orders/1
  # DELETE /purchase_orders/1.json
  def destroy
    @purchase_order = PurchaseOrder.find(params[:id])
    @purchase_order.destroy

    respond_to do |format|
      format.html { redirect_to purchase_orders_path+"?store_id=#{@purchase_order[:store_id]}", notice: 'Purchase order was successfully deleted.'  }
      format.json { head :no_content }
    end
  end

  def print_barcodes
    if @product.sku.present?
      require 'barby'
      require 'barby/barcode/code_128'
      # require 'barby/barcode/ean_13'
      require 'barby/outputter/png_outputter'
      #Barcode generation
      @ean_barcode = Barby::Code128B.new(@product.sku)
      # @ean_barcode = Barby::EAN13.new(@product.sku)
      @png_blob = Barby::PngOutputter.new(@ean_barcode).to_png(:margin => 2, :xdim => 3, :height => 65)
    end
  end
  def send_purchase_order
    @po_log = StockPurchase.new
    @po_log[:purchase_order_id] = params[:id]
    @purchase_order = PurchaseOrder.find(params[:id])
    _mail_send = AppConfiguration.get_config_value('vendor_email')
    respond_to do |format|
      if @po_log.save
        VendorMailer.vendor_email(@purchase_order,currency,@current_user).deliver if _mail_send == "enabled"
        format.json { render json: @po_log }
        format.js
      end
    end
  end

  def get_send_purchase_order_details
    @spo_details = StockPurchase.new
    @spo_details[:purchase_order_id] = params[:id]
    @purchase_order = PurchaseOrder.find(params[:id])
    _vendor_mail_conf = AppConfiguration.get_config_value('vendor_email')
    purchase_order_hash={}
    purchase_order_hash["id"] = params[:id]
    purchase_order_hash["created_at"] = @purchase_order.created_at.strftime("%m-%d-%y")
    purchase_order_hash["vendor"] = {}
    purchase_order_hash["vendor"]["name"]= @purchase_order.vendor.name
    purchase_order_hash["vendor"]["address"]= @purchase_order.vendor.address
    purchase_order_hash["vendor"]["phone"]= @purchase_order.vendor.phone
    purchase_order_hash["vendor"]["gst"] = @purchase_order.vendor.gst_hash
    table_arr=[]
    sl = 0
    @purchase_order.purchase_order_metum.each_with_index do |pod,i|
      table_hash={}
      po_metum_descrptions = pod.purchase_order_metum_descrptions
      if po_metum_descrptions.present?
        po_metum_descrptions.each_with_index do |pomd,j|
          sl = sl + 1
          if pod.product.vendor_products.by_vendor(@purchase_order.vendor.id).first.present?
            price = pod.product.vendor_products.by_vendor(@purchase_order.vendor.id).first.price 
          end
          if price.present?
            total_price = price * pomd.quantity
          end
          table_hash["sl"] = sl
          table_hash["product_name"] = pod.product.name
          if pomd.color.present?
            table_hash["color_name"] = pomd.color.name
          else
            table_hash["color_name"] = "-"
          end
          if pomd.size.present?
            table_hash["size_name"] = pomd.size.name
          else
            table_hash["size_name"] = '-'
          end
          if price.present?
            table_hash["price"] = [price , pod.product.basic_unit].join(" /")
          else
            table_hash["price"] = "-"
          end
          table_hash["quantity"] = [pomd.quantity , pod.product.basic_unit].join(" ")
          if total_price.present?
            table_hash["total_price"] = total_price.round(0)
          else
            table_hash["total_price"] = '-'
          end
        end
      else
        sl = sl + 1
        if pod.price_per_unit.present?
          price = pod.price_per_unit
        else
          if pod.product.vendor_products.by_vendor(@purchase_order.vendor.id).first.present?
            price = pod.product.vendor_products.by_vendor(@purchase_order.vendor.id).first.price
          end
        end
        if price.present?
          total_price = price * pod.product_amount
        end
        table_hash["sl"] = sl
        table_hash["product_name"] = pod.product.name
        table_hash["color_name"] = "-"
        table_hash["size_name"] = '-'
        if pod.product_transaction_unit.present?
          table_hash["price"] = [price , pod.product_transaction_unit.product_unit_name].join(" /")
        else
          table_hash["price"] = [price , pod.product.basic_unit].join(" /")
        end
        if pod.product_transaction_unit.present?
          table_hash["product_unit"] = pod.product_transaction_unit.product_unit_name
          table_hash["quantity"] = [pod.secondary_amount ,pod.product_transaction_unit.product_unit_name].join(" ")
        else
          table_hash["product_unit"] = pod.product.basic_unit
          table_hash["quantity"] = [pod.product_amount , pod.product.basic_unit].join(" ")
        end
        if total_price.present?
          table_hash["total_price"] = total_price.round(0)
        else
          table_hash["total_price"] = '-'
        end
      end
      table_arr.push(table_hash)
    end
    current_user_hash={}
    current_user_hash["unit"]={}
    current_user_hash["id"]=@current_user.id
    current_user_hash["unit"]["unit_name"]=@current_user.unit.unit_name
    current_user_hash["unit"]["address"]=@current_user.unit.address
    current_user_hash["unit"]["phone"]=@current_user.unit.phone
    current_user_hash["unit"]["unit_image"] = @current_user.unit.unit_images.first.image if @current_user.unit.unit_images.present?
    @currency = currency
    respond_to do |format|
      format.json {render json: {purchase_order: purchase_order_hash, currency: @currency, current_user: current_user_hash, table_data: table_arr, mail_conf:_vendor_mail_conf}}
    end
  end



  def send_smart_po
    _mail_send = AppConfiguration.get_config_value('vendor_email')
    @smart_po = SmartPo.find(params[:smart_po_id])
    _sending_error = 0
    @smart_po.purchase_orders.each do |_po|
      @po_log = StockPurchase.new
      @po_log[:purchase_order_id] = _po.id
      if @po_log.save
        _sending_error = _sending_error
      else
        _sending_error += 1
      end
    end
    respond_to do |format|
      if _sending_error == 0
        VendorMailer.vendor_smart_po_email(@smart_po,currency,@current_user).deliver if _mail_send == "enabled"
        format.json { render json: @smart_po }
      end
    end
  end

  def product_vendors
    @purchase_order = PurchaseOrder.new
    @store = Store.find(params[:store_id])
    @vendors = Vendor.where(:unit_id => @current_user.unit_id)
    product_arr = params['checked_product']
    @product_scope = Product.find_all_by_id(product_arr)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def save_purchase_order
    @store = Store.find(params[:store_id])
    params[:vendor_id].each do |vendor|
      if params["checked_product_#{vendor}"].present?
        _purchase_order = PurchaseOrder.new
        _purchase_order[:name]=params['name']
        _purchase_order[:store_id]=params['store_id']
        _purchase_order[:valid_from]=params['valid_from']
        _purchase_order[:valid_till]=params['valid_till']
        _purchase_order[:vendor_id]=vendor
        _purchase_order[:user_id]=current_user.id
        _purchase_order[:unit_id]=current_user.unit_id
        _purchase_order[:recurring]=0
        _purchase_order[:purchase_order_code]="PO"+(Time.now.to_i).to_s+"#{rand(1000)}"
        _purchase_order.save
        params["checked_product_#{vendor}"].each do |product|
          _purchase_order_metum = PurchaseOrderMetum.new
          _purchase_order_metum[:purchase_order_id] = _purchase_order.id
          _purchase_order_metum[:product_id] = product
          _purchase_order_metum[:product_amount] = params["quantity#{product}"]
          _purchase_order_metum.save
        end
      end
    end
    redirect_to store_path(@store), notice: 'Purchase order was successfully created.'
  end

  def save_pom
    _purchase_order_metum = PurchaseOrderMetum.new
    _purchase_order_metum[:purchase_order_id] = params[:purchase_order_id]
    _purchase_order_metum[:product_id] = Product.find_by_name(params[:product_name]).id
    _purchase_order_metum[:product_amount] = 1
    _purchase_order_metum.save

    _basic_unit = _purchase_order_metum.product.basic_unit
    _current_stock = [get_product_current_stock(_purchase_order_metum.purchase_order.store_id, _purchase_order_metum.product_id),_basic_unit].join(" ")

    respond_to do |format|
      # format.json { render json: _purchase_order_metum }
      format.json { render json: {all_data: {data: _purchase_order_metum, product_basic_unit: _basic_unit, current_stock: _current_stock}}}
    end
  end

  def remove_pom
    _purchase_order_metum = PurchaseOrderMetum.find(params[:pom_id])
    if _purchase_order_metum.destroy
      if _purchase_order_metum.purchase_order_metum_descrptions.present?
        _purchase_order_metum.purchase_order_metum_descrptions.destroy_all
      end
    end
    respond_to do |format|
      format.json { render json: _purchase_order_metum }
    end
  end

  def update_pom
    _purchase_order_metum = PurchaseOrderMetum.find(params[:pom_id])
    _purchase_order_metum.update_attribute(:product_amount,params[:quantity])
    respond_to do |format|
      format.json { render json: _purchase_order_metum }
    end
  end

  def update_pomd
    _pomd = PurchaseOrderMetumDescrption.set_purchase_order_metum_descriptions(params[:po_id],params[:pom_id],params[:product_id],params[:color_id],params[:size_id]).first
    if _pomd.present?
      _pomd.update_attribute(:quantity,params[:quantity])
    else
      _new_pomd = PurchaseOrderMetumDescrption.new
      _new_pomd.purchase_order_id = params[:po_id]
      _new_pomd.purchase_order_metum_id = params[:pom_id]
      _new_pomd.product_id = params[:product_id]
      _new_pomd.color_id = params[:color_id]
      _new_pomd.size_id = params[:size_id]
      _new_pomd.quantity = params[:quantity]

      _new_pomd.save
    end
    _purchase_order_metum = PurchaseOrderMetum.find(params[:pom_id])
    respond_to do |format|
      format.json { render json: _purchase_order_metum }
    end
  end

  def remove_all_pomd
    _pom = PurchaseOrderMetum.find(params[:pom_id])
    _pom.purchase_order_metum_descrptions.destroy_all
    respond_to do |format|
      format.json { render json: _pom }
    end
  end
  def vendor_product_price
    vendor_price = VendorProduct.by_vendor_product(params[:product_id],params[:vendor_id]).last
    respond_to do |format|
      # format.json { render json: vendor_price }
      format.json { render json: vendor_price.to_json(:include => :product) }
    end
  end

  def cancel_po
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        @store = Store.find(params[:store_id])
        @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
        if @purchase_order.update_column(:status,'cancelled')
          @purchase_order.purchase_order_metum.update_all(:status => 'cancelled')
          redirect_to store_path(@store), notice: 'Purchase Order is successfully cancelled'
        else
          redirect_to store_path(@store), alert: 'Something went wrong'
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_store_purchase_order_path(@store)+"?vendor_id=#{params[:purchase_order][:vendor_id]}&business_type=#{params[:purchase_order][:business_type]}", alert: e.message
    end
  end

  def cancel_po_item
    @purchase_order = PurchaseOrder.find(params[:po_id])
    @po_meta = PurchaseOrderMetum.find(params[:meta_id])
    respond_to do |format|
      if @po_meta.update_column(:status, 'cancelled')
        @purchase_order.update_column(:status, 'cancelled') if @purchase_order.purchase_order_metum.count == @purchase_order.purchase_order_metum.cancelled.count
        format.json { render json: @purchase_order }
        format.js
      end
    end
  end

  private
  def set_module_details
    @module_id = "inventory"
    @module_title = "Inventory"
  end
end
