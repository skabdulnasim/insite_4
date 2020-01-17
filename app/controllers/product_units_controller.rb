class ProductUnitsController < ApplicationController
  # GET /product_units
  # GET /product_units.json
  load_and_authorize_resource
  def index
    @product_units = ProductUnit.order("created_at")
    @product_units = @product_units.by_basic_unit(params[:product_basic_unit_id]) if params[:product_basic_unit_id].present?
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @product_units }
    end
  end

  # GET /product_units/1
  # GET /product_units/1.json
  def show
    @product_unit = ProductUnit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_unit }
    end
  end

  # GET /product_units/new
  # GET /product_units/new.json
  def new
    @product_unit = ProductUnit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product_unit }
      format.js
    end
  end

  # GET /product_units/1/edit
  def edit
    @product_unit = ProductUnit.find(params[:id])
  end

  # POST /product_units
  # POST /product_units.json
  def create
    @product_unit = ProductUnit.new(params[:product_unit])

    respond_to do |format|
      if @product_unit.save
        format.html { redirect_to products_settings_path, notice: 'Product unit was successfully created.' }
        format.json { render json: @product_unit, status: :created, location: @product_unit }
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @product_unit.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PUT /product_units/1
  # PUT /product_units/1.json
  def update
    @product_unit = ProductUnit.find(params[:id])

    respond_to do |format|
      if @product_unit.update_attributes(params[:product_unit])
        format.html { redirect_to products_settings_path, notice: 'Product unit was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: "edit" }
        format.json { render json: @product_unit.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /product_units/1
  # DELETE /product_units/1.json
  def destroy
    @product_unit = ProductUnit.find(params[:id])
    @product_unit.destroy

    respond_to do |format|
      format.html { redirect_to products_settings_url, notice: 'Product unit was successfully deleted.' }
      format.json { head :no_content }
      format.js
    end
  end
end
