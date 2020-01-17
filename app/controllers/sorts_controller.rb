include SortsHelper
class SortsController < ApplicationController
  load_and_authorize_resource :except => [:get_order_details, :get_order_by_id]
  
  layout "material"
  before_filter :set_module_details

  # GET /sorts
  # GET /sorts.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  sorts_index_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def index
    if params[:device_id].present?
      sort_scope = Sort.where(:id != nil)
    else
      @sorts = Sort.current_unit_sorts(current_user.unit_id)
    end 
    sort_scope = sort_scope.current_unit_sorts(params[:unit_id]) if params[:unit_id].present?

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: sort_scope }
    end
  end

  # GET /sorts/1
  # GET /sorts/1.json
  def show
    @sort = Sort.find(params[:id])
    @sort_items = @sort.order_details.order('id DESC')
    @today_sort_items = @sort.order_details.today.order('id DESC')

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sort }
    end
  end

  # GET /sorts/new
  # GET /sorts/new.json
  def new
    @sort = Sort.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sort }
    end
  end

  # GET /sorts/1/edit
  def edit
    @sort = Sort.find(params[:id])
  end

  # POST /sorts
  # POST /sorts.json
  def create
    @sort = Sort.new(params[:sort])

    respond_to do |format|
      if @sort.save
        format.html { redirect_to sorts_url, notice: 'Sort was successfully created.' }
        format.json { render json: @sort, status: :created, location: @sort }
      else
        format.html { render action: "new" }
        format.json { render json: @sort.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sorts/1
  # PUT /sorts/1.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  update_sort_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def update
    @sort = Sort.find(params[:id])
    if params[:device_id].present?
      begin
        raise "Device IP or Port not available" unless params[:tab_ip].present? and params[:port_no].present?
        @sort.update_attributes(:tab_ip => params[:tab_ip], :port_no => params[:port_no])
        respond_to do |format|
          format.json { render json: {:success => "SORT has been successfully updated"} }
        end
      rescue Exception => e
        Rscratch::Exception.log e,request
        respond_to do |format|
          format.json { render json: {:error => e.message} }
        end
      end
    else
      respond_to do |format|
        if @sort.update_attributes(params[:sort])
          format.html { redirect_to @sort, notice: 'Sort was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sort.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /sorts/1
  # DELETE /sorts/1.json
  def destroy
    @sort = Sort.find(params[:id])
    @sort.destroy

    respond_to do |format|
      format.html { redirect_to sorts_url }
      format.json { head :no_content }
    end
  end

  def get_order_by_id
    order_id = params[:order_id]
    @order_scope = Order.find(order_id)
    rescue Exception => @error
  end

  def get_order_details
    @order_hash = {}
    delivery_hash = {}
    #@order_hash[:table_orders]      = Sort.get_table_orders(params[:unit_id],params[:status_ids])
    @order_hash[:table_orders]      = Sort.get_resource_orders(params[:unit_id],params[:status_ids])
    delivery_hash[:home_orders]     = Sort.get_home_orders(params[:unit_id],params[:status_ids])
    delivery_hash[:section_orders]  = Sort.get_section_orders(params[:unit_id],params[:status_ids])
    delivery_hash[:pickup_orders]   = Sort.get_pickup_orders(params[:unit_id],params[:status_ids])
    @order_hash[:non_table_orders]  = delivery_hash
    @order_hash[:sorts]             = Sort.where('is_trashed=? AND unit_id=?', FALSE,params[:unit_id]).select('id,name')
    rescue Exception => @error
  end
  
  private

  def set_module_details
    @module_id = "sort"
    @module_title = "SORT"
  end  

end
