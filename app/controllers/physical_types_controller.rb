class PhysicalTypesController < ApplicationController
  # GET /physical_types
  # GET /physical_types.json
  load_and_authorize_resource
  def index
    @physical_types = PhysicalType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @physical_types }
    end
  end

  # GET /physical_types/1
  # GET /physical_types/1.json
  def show
    @physical_type = PhysicalType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @physical_type }
    end
  end

  # GET /physical_types/new
  # GET /physical_types/new.json
  def new
    @physical_type = PhysicalType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @physical_type }
    end
  end

  # GET /physical_types/1/edit
  def edit
    @physical_type = PhysicalType.find(params[:id])
  end

  # POST /physical_types
  # POST /physical_types.json
  def create
    @physical_type = PhysicalType.new(params[:physical_type])
    
    respond_to do |format|
      if @physical_type.save
        format.html { redirect_to products_settings_path, notice: 'Physical type was successfully created.' }
        format.json { render json: @physical_type, status: :created, location: @physical_type }
      else
        format.html { render action: "new" }
        format.json { render json: @physical_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /physical_types/1
  # PUT /physical_types/1.json
  def update
    @physical_type = PhysicalType.find(params[:id])

    respond_to do |format|
      if @physical_type.update_attributes(params[:physical_type])
        format.html { redirect_to @physical_type, notice: 'Physical type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @physical_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /physical_types/1
  # DELETE /physical_types/1.json
  def destroy
    @physical_type = PhysicalType.find(params[:id])
    @physical_type.destroy

    respond_to do |format|
      format.html { redirect_to products_settings_path, notice: 'Physical type was successfully deleted.'  }
      format.json { head :no_content }
    end
  end
end
