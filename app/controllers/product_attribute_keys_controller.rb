class ProductAttributeKeysController < ApplicationController
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
    
  before_filter :set_module_details

  # GET /product_attribute_keys
  # GET /product_attribute_keys.json
  def index
    @product_attribute_keys = ProductAttributeKey.order('created_at desc')
    smart_listing_create :attributes, @product_attribute_keys, partial: "product_attribute_keys/attribute_smartlist", default_sort: {created_at: "desc"}
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @product_attribute_keys }
    end
  end

  # GET /product_attribute_keys/1
  # GET /product_attribute_keys/1.json
  def show
    @product_attribute_key = ProductAttributeKey.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_attribute_key }
    end
  end

  # GET /product_attribute_keys/new
  # GET /product_attribute_keys/new.json
  def new
    @product_attribute_key = ProductAttributeKey.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product_attribute_key }
    end
  end

  # GET /product_attribute_keys/1/edit
  def edit
    @product_attribute_key = ProductAttributeKey.find(params[:id])
  end

  # POST /product_attribute_keys
  # POST /product_attribute_keys.json
  def create
    @product_attribute_key = ProductAttributeKey.new(params[:product_attribute_key])

    respond_to do |format|
      if @product_attribute_key.save
        format.html { redirect_to @product_attribute_key, notice: 'Product attribute key was successfully created.' }
        format.json { render json: @product_attribute_key, status: :created, location: @product_attribute_key }
      else
        format.html { render action: "new" }
        format.json { render json: @product_attribute_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_attribute_keys/1
  # PATCH/PUT /product_attribute_keys/1.json
  def update
    @product_attribute_key = ProductAttributeKey.find(params[:id])

    respond_to do |format|
      if @product_attribute_key.update_attributes(params[:product_attribute_key])
        format.html { redirect_to @product_attribute_key, notice: 'Product attribute key was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product_attribute_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_attribute_keys/1
  # DELETE /product_attribute_keys/1.json
  def destroy
    @product_attribute_key = ProductAttributeKey.find(params[:id])
    @product_attribute_key.destroy

    respond_to do |format|
      format.html { redirect_to product_attribute_keys_url }
      format.json { head :no_content }
    end
  end

  private
    
    def set_module_details
      @module_id = "products"
      @module_title = "Products"
    end  

end
