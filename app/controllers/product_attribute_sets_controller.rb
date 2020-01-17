class ProductAttributeSetsController < ApplicationController
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details

  # GET /product_attribute_sets
  # GET /product_attribute_sets.json
  def index
    @product_attribute_sets = ProductAttributeSet.order('created_at desc')
    smart_listing_create :attribute_sets, @product_attribute_sets, partial: "product_attribute_sets/attribute_set_smartlist", default_sort: {created_at: "desc"}
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @product_attribute_sets }
    end
  end

  # GET /product_attribute_sets/1
  # GET /product_attribute_sets/1.json
  def show
    @product_attribute_set = ProductAttributeSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_attribute_set }
    end
  end

  # GET /product_attribute_sets/new
  # GET /product_attribute_sets/new.json
  def new
    @product_attribute_set = ProductAttributeSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product_attribute_set }
    end
  end

  # GET /product_attribute_sets/1/edit
  def edit
    @product_attribute_set = ProductAttributeSet.find(params[:id])
  end

  # POST /product_attribute_sets
  # POST /product_attribute_sets.json
  def create
    @product_attribute_set = ProductAttributeSet.new(product_attribute_set_params)

    respond_to do |format|
      if @product_attribute_set.save
        format.html { redirect_to @product_attribute_set, notice: 'Product attribute set was successfully created.' }
        format.json { render json: @product_attribute_set, status: :created, location: @product_attribute_set }
      else
        format.html { render action: "new" }
        format.json { render json: @product_attribute_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_attribute_sets/1
  # PATCH/PUT /product_attribute_sets/1.json
  def update
    @product_attribute_set = ProductAttributeSet.find(params[:id])

    respond_to do |format|
      if @product_attribute_set.update_attributes(product_attribute_set_params)
        format.html { redirect_to @product_attribute_set, notice: 'Product attribute set was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product_attribute_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_attribute_sets/1
  # DELETE /product_attribute_sets/1.json
  def destroy
    @product_attribute_set = ProductAttributeSet.find(params[:id])
    @product_attribute_set.destroy

    respond_to do |format|
      format.html { redirect_to product_attribute_sets_url }
      format.json { head :no_content }
    end
  end

  def seed
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        ProductAttributeSet.seed_data
      end
      redirect_to product_attribute_sets_path, notice: 'Default attribute set has been successfully loaded.'
    rescue Exception => e
      redirect_to product_attribute_sets_path, alert: e.message.to_s
    end
  end

  private

    def set_module_details
      @module_id = "products"
      @module_title = "Products"
    end
    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def product_attribute_set_params
      params.require(:product_attribute_set).permit(:deleted_at, :is_default, :name)
    end
end
