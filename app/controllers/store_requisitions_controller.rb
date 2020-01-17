class StoreRequisitionsController < ApplicationController
  #Cancan Authorization
  load_and_authorize_resource :except => [:send_requisition, :copy_requisition]
  
  #Including required libraries
  require 'json'
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  #Defining layouts
  layout "material"

  #Controller filters
  before_filter :set_module_details
  
  # GET /store_requisitions
  # GET /store_requisitions.json  
  def index
    @store_id = params[:store_id]
    @store = Store.find(@store_id)
    @store_requisitions = StoreRequisition.where(:store_id => @store_id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @store_requisitions.to_json(:include => [:from_store,:destination_store,{:store_requisition_metum => {:include => :product}}]) }
    end
  end

  # GET /store_requisitions/1
  # GET /store_requisitions/1.json
  def show
    @store = Store.find(params[:store_id])
    @store_requisition = StoreRequisition.find(params[:id])
    if !@store_requisition.requisition_details.nil?
      @store_requisition_details = JSON.parse(@store_requisition.requisition_details)
    end
    @store_requisition_products = StoreRequisitionMetum.where(:requisition_id => @store_requisition.id)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @store_requisition }
    end
  end

  # GET /store_requisitions/new
  # GET /store_requisitions/new.json
  def new
    @store = Store.find(params[:store_id])
    @store_requisition = StoreRequisition.new
    @destination_store = (AppConfiguration.get_config_value('stock_transfer_to_secondary_store') == 'enabled') ? Store.store_id_not(@store.id).not_return.primary_secondery : Store.store_id_not(@store.id).physical.primary

    # Store.find(:all, :conditions => ["id !=? and store_type =?", params[:store_id], 'physical_store'], :order => "created_at DESC")
    # @other_storage_locations = Store.find(:all, :conditions => ["id !=? and store_type =?", params[:store_id], 'physical_store'], :order => "created_at DESC")
    @categories = Category.all
    #product_scope = Product.get_all
    product_scope = @store.products.where(:business_type=> params[:business_type]).present? ? @store.products : Product.where(:business_type=> params[:business_type])
    product_scope = product_scope.filter_by_product_type(params[:product_type]) if params[:product_type].present?
    product_scope = product_scope.filter_by_product_category(params[:product_category]) if params[:product_category].present?
    product_scope = product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    product_scope = product_scope.filter_by_itemcode_brand_mfr(params[:itemcode_brand_mfr]) if params[:itemcode_brand_mfr].present?
    # product_scope = product_scope.filter_by_brand_name(params[:itemcode_brand_mfr]) if params[:itemcode_brand_mfr].present?
    # product_scope = product_scope.filter_by_mfr_name(params[:itemcode_brand_mfr]) if params[:itemcode_brand_mfr].present?
    smart_listing_create :products, product_scope, partial: "products/product_input_smartlist", default_sort: {id: "desc"}

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @store_requisition }
    end
  end

  # GET /store_requisitions/1/edit
  def edit
    @store_requisition = StoreRequisition.find(params[:id])
    @store_id = params[:store_id]
    @current_user_id=get_current_user_id()
    @current_user_info = UserManagement::get_current_user(@current_user_id)
  end

  # POST /store_requisitions
  # POST /store_requisitions.json
  # Backup
  # def create
  #   begin
  #     ActiveRecord::Base.transaction do # Protective transaction block
  #       _store_requisition = StoreRequisition.new(params[:store_requisition])
  #       @store = Store.find(_store_requisition[:store_id])
  #       raise 'No products selected for new requisition.' unless !params[:checked_raw].nil?
  #       raise 'No destination store selected.' unless params[:store_requisition][:to_store].present?
  #       _store_requisition[:user_id]=current_user.id
  #       _store_requisition[:unit_id]=current_user.unit_id
  #       _store_requisition[:recurring]=0
  #       _store_requisition[:requisition_code]="req"+(Time.now.to_i).to_s+"#{rand(1000)}"
  #       _store_requisition.save
  #       params[:checked_raw].each do |c|
  #         _store_requisition_metum = StoreRequisitionMetum.new(params[:store_requisition_metum])
  #         _store_requisition_metum[:product_id] = c
  #         _store_requisition_metum[:product_ammount] = params["quantity#{c}"]
  #         _store_requisition.store_requisition_metum << _store_requisition_metum
  #       end
  #       if params[:future_orders].present?
  #         params[:future_orders].split(',').each do |future_order_id|
  #           Order.find(future_order_id).update_column(:is_requisitioned,1)
  #         end
  #       end

  #       if params[:send_requisition].present? && params[:send_requisition] == 'yes'
  #         @req_log = StoreRequisitionLog.new
  #         @req_log[:store_requisition_id] = _store_requisition.id
  #         if params[:expected_received_date].present?
  #           @req_log[:expected_received_date] = params[:expected_received_date]
  #         end
  #         if @req_log.save
  #           _metums = StoreRequisitionMetum.set_requistion(@req_log.store_requisition_id)
  #           _metums.each do |meta|  
  #             @log_items = LogItem.new
  #             @log_items[:log_id]               = @req_log.id
  #             @log_items[:from_store_id]        = @req_log.from_store_id
  #             @log_items[:store_id]             = @req_log.store_id
  #             @log_items[:store_requisition_id] = @req_log.store_requisition_id
  #             @log_items[:product_id]           = meta.product_id
  #             @log_items[:product_ammount]      = meta.product_ammount
  #             @log_items[:status]               = '1'
  #             @log_items.save
  #           end  
  #         end
  #       end

  #       respond_to do |format|
  #         format.html { redirect_to store_path(@store), notice: 'Requisition was successfully created.' }
  #       end        
  #     end
  #   rescue Exception => e
  #     Rscratch::Exception.log e,request
  #     respond_to do |format|
  #       format.html { redirect_to new_store_store_requisition_path(@store)+"?business_type=#{params[:store_requisition][:business_type]}", alert: e.message }
  #     end      
  #   end
  # end

  def create
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        _store_requisition = StoreRequisition.new(params[:store_requisition])
        @store = Store.find(_store_requisition[:store_id])
        raise 'No products selected for new requisition.' unless !params[:checked_raw].nil? or !params[:checked_raw_single_product].nil?
        raise 'No destination store selected.' unless params[:store_requisition][:to_store].present?
        _store_requisition[:user_id]=current_user.id
        _store_requisition[:unit_id]=current_user.unit_id
        _store_requisition[:recurring]=0
        _store_requisition[:requisition_code]="req"+(Time.now.to_i).to_s+"#{rand(1000)}"
        _store_requisition.save
        if params[:checked_raw].present?
          params[:checked_raw].each do |c|
            _store_requisition_metum = StoreRequisitionMetum.new(params[:store_requisition_metum])
            _store_requisition_metum[:product_id] = c
            _store_requisition_metum[:product_ammount] = params["quantity#{c}"]
            _store_requisition.store_requisition_metum << _store_requisition_metum
          end
        end
        if params["checked_raw_single_product"].present?
          params["checked_raw_single_product"].each do |color_size_product|
            _color_size_split = color_size_product.split('_')
            _product_id = _color_size_split[0]
            _color_id = _color_size_split[1]
            _size_id = _color_size_split[2]
            _store_requisition_metum = StoreRequisitionMetum.new
            _store_requisition_metum[:product_id] = _product_id
            _store_requisition_metum[:product_ammount] = params["single_item_quantity#{color_size_product}"]
            if _size_id.to_i != 0
              _store_requisition_metum[:size_id] = _size_id
            end 
            if _color_id.to_i != 0 
              _store_requisition_metum[:color_id] = _color_id
            end
            _store_requisition.store_requisition_metum << _store_requisition_metum
          end
        end
        if params[:future_orders].present?
          params[:future_orders].split(',').each do |future_order_id|
            Order.find(future_order_id).update_column(:is_requisitioned,1)
          end
        end

        if params[:send_requisition].present? && params[:send_requisition] == 'yes'
          @req_log = StoreRequisitionLog.new
          @req_log[:store_requisition_id] = _store_requisition.id
          if params[:expected_received_date].present?
            @req_log[:expected_received_date] = params[:expected_received_date]
          end
          if @req_log.save
            _metums = StoreRequisitionMetum.set_requistion(@req_log.store_requisition_id)
            _metums.each do |meta|  
              @log_items = LogItem.new
              @log_items[:log_id]               = @req_log.id
              @log_items[:from_store_id]        = @req_log.from_store_id
              @log_items[:store_id]             = @req_log.store_id
              @log_items[:store_requisition_id] = @req_log.store_requisition_id
              @log_items[:product_id]           = meta.product_id
              @log_items[:product_ammount]      = meta.product_ammount
              @log_items[:status]               = '1'
              @log_items[:color_id]             = meta.color_id
              @log_items[:size_id]              = meta.size_id
              @log_items.save
            end  
          end
        end

        respond_to do |format|
          format.html { redirect_to store_path(@store), notice: 'Requisition was successfully created.' }
        end        
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.html { redirect_to new_store_store_requisition_path(@store)+"?business_type=#{params[:store_requisition][:business_type]}", alert: e.message }
      end      
    end
  end

  # PUT /store_requisitions/1
  # PUT /store_requisitions/1.json
  def update
    @store_requisition = StoreRequisition.find(params[:id])
    respond_to do |format|
      if @store_requisition.update_attributes(params[:store_requisition])
        format.html { redirect_to store_requisitions_path+"?store_id=#{@store_requisition[:store_id]}" , notice: 'Requisition was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @store_requisition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /store_requisitions/1
  # DELETE /store_requisitions/1.json
  def destroy
    @store_requisition = StoreRequisition.find(params[:id])
    _store = Store.find(@store_requisition.store_id)
    @store_requisition.destroy
    @store_requisition_metum = StoreRequisitionMetum.where(:requisition_id => params[:id])
    @store_requisition_metum.each do |store_requisition_metum|
      store_requisition_metum.destroy
    end

    respond_to do |format|
      format.html { redirect_to store_store_requisitions_path(_store) , notice: 'Requisition was successfully deleted.' }
      format.json { head :no_content }
    end
  end
  
  def save_store_requisition
    @requisition_details = {}
    @requisition_type = params[:requisition_type]
    if @requisition_type == "delay"
      if params[:delayed_date] != "" && params[:delayed_time] != ""
        @store_requisition = StoreRequisition.find(params[:id])
        @requisition_details[:requisition_type] = "delay"
        @requisition_details[:date] = params[:delayed_date]
        @requisition_details[:time] = params[:delayed_time]
        @requisition_details_json = JSON.generate(@requisition_details)
        @store_requisition[:requisition_details] = @requisition_details_json
        @store_requisition[:recurring] = 1
      end
    end
    
    if @requisition_type == "recurring"
      if params[:recurring_type] != "" && params[:days] != "" && params[:times] != ""
        @store_requisition = StoreRequisition.find(params[:id])
        @requisition_details[:requisition_type] = "recurring"
        @requisition_details[:recurring_type] = params[:recurring_type]
        @requisition_details[:days] = params[:days]
        @requisition_details[:times] = params[:times]
        @requisition_details_json = JSON.generate(@requisition_details)
        @store_requisition[:requisition_details] = @requisition_details_json
        @store_requisition[:recurring] = 1
        
        # cron scheduler creation
        requisitio_code = @store_requisition.requisition_code
        cron_schedule_string = UtilityManagement::get_cron_argument( @requisition_details[:days], @requisition_details[:times])
        
        # Create Cron Job from Hash
        cron_config = Hash.new
        cron_config[requisitio_code]=  {
               'class' => 'RequisitionScheduler',
               'cron'  => cron_schedule_string,
               'args'  => {:id =>params[:id]}
        }
        
        Sidekiq::Cron::Job.load_from_hash cron_config
        # End of create Cron Job from hash

        # Create Cron Job using new
        #job = Sidekiq::Cron::Job.new( name: requisitio_code, cron: cron_schedule_string, klass: RequisitionScheduler, args:{:id =>params[:id]})
          #unless job.save
            #puts job.errors #will return array of errors
          #end
         # End of create Cron Job using new
      end
    end
    
    respond_to do |format|
      if @store_requisition.update_attributes(params[:store_requisition])
        format.html { redirect_to store_requisitions_path+"?store_id=#{@store_requisition[:store_id]}" , notice: 'Requisition was successfully updated.' }
        format.json { render json: @msg }
      else
        format.html { render action: "edit" }
        format.json { render json: @msg }
      end
    end
  end
  
  
  def send_requisition
    @req_log = StoreRequisitionLog.new
    @req_log[:store_requisition_id] = params[:id]
    respond_to do |format|
      if @req_log.save
        _metums = StoreRequisitionMetum.set_requistion(@req_log.store_requisition_id)
        _metums.each do |meta|  
          @log_items = LogItem.new
          @log_items[:log_id]               = @req_log.id
          @log_items[:from_store_id]        = @req_log.from_store_id
          @log_items[:store_id]             = @req_log.store_id
          @log_items[:store_requisition_id] = @req_log.store_requisition_id
          @log_items[:product_id]           = meta.product_id
          @log_items[:product_ammount]      = meta.product_ammount
          @log_items[:status]               = '1'
          @log_items[:color_id]             = meta.color_id
          @log_items[:size_id]              = meta.size_id
          @log_items.save
        end  
        format.json { render json: @req_log }
      end
    end
  end
  
  def copy_requisition
    requisition_id = params[:copy_from_id]
    @requisition_meta_details = StoreRequisitionMetum.where(:requisition_id => requisition_id) 
    respond_to do |format|
      format.json { render :json => @requisition_meta_details}
    end
  end

  def get_requisition_details
    _log_details = StoreRequisitionLog.find(params[:log_id])
    respond_to do |format|
      format.json { render json: _log_details.to_json(:include => {:store_requisition => {:include => {:store_requisition_metum => {:include => :product}}}} ) }
    end
  end

  def update_requisition_state
    _log_details = StoreRequisitionLog.find(params[:log_id])
    @store = Store.find(_log_details.store_id)
    respond_to do |format|
      if _log_details.update_attribute(:status, params[:status])
        LogItem.where(:log_id =>params[:log_id]).update_all(:status => params[:status])
        format.html { redirect_to store_path(@store) , notice: 'Requisition was successfully updated.' }
        format.json { render json: _log_details }
      else
        format.html { redirect_to store_path(@store) , notice: 'Error occured while updating requisition' }
        format.json { render json: @msg }
      end
    end
  end

  def requisition_summary
    @store_requisition = StoreRequisition.new
    @store = Store.find(params[:store_id])
    #@destination_stores = (AppConfiguration.get_config_value('stock_transfer_to_secondary_store') == 'enabled') ? Store.store_id_not(@store.id).physical : Store.store_id_not(@store.id).physical.primary
    @destination_stores = Store.store_id_not(@store.id)
    @rq_date = params[:requisitions_date].present? ? params[:requisitions_date] : Date.today
    requestions = StoreRequisitionLog.select("COUNT(store_requisition_id) AS count, store_requisition_id").group(:store_requisition_id).store_requistion(params[:store_id]).na_requisitions.by_created_at(@rq_date)  
    @summary_requisitions = {}
    requestions.each do |data| 
      @product_details = StoreRequisitionMetum.get_product_details(data,@rq_date).order("product_id")
      @product_details.each do |product|
        if  @summary_requisitions.has_key? product.product_id
          @summary_requisitions[product.product_id]["total_amount"] = @summary_requisitions[product.product_id]["total_amount"].to_f+product.total_amount.to_f
        else
          @summary_requisitions[product.product_id] = {'total_amount'=>product.total_amount.to_f}
        end
      end  
    end
    @summary_requisitions_bom = {}
    @summary_requisitions.each do |p_id,p_quantity|
      raw_products = ProductComposition.set_product(p_id)
      if raw_products.present?
        raw_products.each do |raw_product|
          raw_product_id = raw_product.raw_product_id
          raw_product_qty = raw_product.raw_product_quantity * p_quantity['total_amount']
          if @summary_requisitions_bom.has_key? raw_product_id
            @summary_requisitions_bom[raw_product_id]['raw_product_total_qty'] += raw_product_qty
          else
            @summary_requisitions_bom[raw_product_id] = {'raw_product_total_qty'=>raw_product_qty}
          end
        end
      end
    end
    respond_to do |format|
      format.js
      format.html 
      format.pdf { render :layout => false } # Add this line
      format.csv { send_data requisition_summary_to_csv(@summary_requisitions,@store), filename: "summary_requisitions-#{params[:from_date]}.csv" }
    end 
  end

  def get_summary_details
    _requisition_meta_details = LogItem.set_product_in(params[:product_id]).na_requisitions.store_requistion(params[:store_id]).by_created_at(params[:rq_date]) 
    respond_to do |format|
      format.json { render json: _requisition_meta_details, :include => {:store => {:only => :name}} }
      #format.json { render :json => _requisition_meta_details.to_json(:include => {:product => {:only => [:name]},:store => {:only => [:name]}}
#)}
    end  
  end


  private
  
  def set_module_details
    @module_id = "inventory"
    @module_title = "Inventory"
  end  

  def requisition_summary_to_csv(data,store)
    CSV.generate do |csv|
      _title = ["product", "Quantity", "Stock"]
      csv << _title
      data.each do |product_id,data|
        basic_unit = Product.find(product_id).basic_unit 
        product_name = Product.find(product_id).name 
        _row = Array.new
        _row.push(product_name)
        _row.push(data['total_amount'])
        _row.push(number_with_precision(get_product_current_stock(store.id, product_id)))
        csv << _row
      end
    end 
  end
  

end
