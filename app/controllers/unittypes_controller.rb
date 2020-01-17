class UnittypesController < ApplicationController
  load_and_authorize_resource

  layout "material"
  before_filter :set_module_details

  def index
    redirect_to units_path
  end
  # GET /unittypes/1
  # GET /unittypes/1.json
  def show
    @unittype = Unittype.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @unittype }
    end
  end
  # GET /unittypes/new
  # GET /unittypes/new.json
  def new
    @unittype = Unittype.new 
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @unittype }
    end
  end  
  # GET /unittypes/1/edit
  def edit
    @unittype = Unittype.find(params[:id])
    @unittypes = Unittype.order('unit_type_priority ASC')
  end
  
  # POST /unittypes
  # POST /unittypes.json
  def create
    @unittype = Unittype.new(params[:unittype])
    @unittypes = Unittype.order('unit_type_priority ASC')
    respond_to do |format|
        if @unittype.save
          format.html { redirect_to units_path, notice: I18n.t('unittype.create.notice') }
          format.js
          format.json { render json: @unittype, status: :created, location: @unittype }
        else
          format.html { render action: "../units/new" }
          format.js
          format.json { render json: @unittype.errors, status: :unprocessable_entity }
        end
    end
  end
  
  # PUT /unittypes/1
  # PUT /unittypes/1.json
  def update
    @unittype = Unittype.find(params[:id])
    respond_to do |format|
      if @unittype.update_attributes(params[:unittype])
        format.html { redirect_to units_path, notice: I18n.t('unittype.update.notice') }
        format.js
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.js
        format.json { render json: @unittype.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /unittypes/1
  # DELETE /unittypes/1.json
  def destroy
    @unittype = Unittype.find(params[:id])
    begin
      @unittype.destroy    
      respond_to do |format|
        format.html { redirect_to units_url, notice: I18n.t('unittype.destroy.notice')  }
        format.js
      end
    rescue Exception => @error
      respond_to do |format|
        format.html { redirect_to units_url, alert: @error.message  }
        format.js
      end      
    end
  end

  def sort
    params[:unittype].each_with_index do |id, index| 
      Unittype.update_all({position: index+1, unit_type_priority: index+1}, {id: id})
    end
    render nothing: true
  end

  #fetch unit parent dropdown while creating a unit depending on the value of the unit type that we will create
  def fetch_units
    type_info = Unittype.fetch_units_from_unittype(params[:id])
    
    respond_to do |format|
      format.json { render :json => type_info}
      end
    end
  private 

  def set_module_details
    @module_id = "units"
    @module_title = "Branches"
  end
end
