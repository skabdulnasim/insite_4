class ProductAttributeOptionsController < ApplicationController
  # GET /product_attribute_options
  # GET /product_attribute_options.json
  def index
    @product_attribute_options = ProductAttributeOption.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @product_attribute_options }
    end
  end

  # GET /product_attribute_options/1
  # GET /product_attribute_options/1.json
  def show
    @product_attribute_option = ProductAttributeOption.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_attribute_option }
    end
  end

  # GET /product_attribute_options/new
  # GET /product_attribute_options/new.json
  def new
    @product_attribute_option = ProductAttributeOption.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product_attribute_option }
    end
  end

  # GET /product_attribute_options/1/edit
  def edit
    @product_attribute_option = ProductAttributeOption.find(params[:id])
  end

  # POST /product_attribute_options
  # POST /product_attribute_options.json
  def create
    @product_attribute_option = ProductAttributeOption.new(product_attribute_option_params)

    respond_to do |format|
      if @product_attribute_option.save
        format.html { redirect_to @product_attribute_option, notice: 'Product attribute option was successfully created.' }
        format.json { render json: @product_attribute_option, status: :created, location: @product_attribute_option }
      else
        format.html { render action: "new" }
        format.json { render json: @product_attribute_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_attribute_options/1
  # PATCH/PUT /product_attribute_options/1.json
  def update
    @product_attribute_option = ProductAttributeOption.find(params[:id])

    respond_to do |format|
      if @product_attribute_option.update_attributes(product_attribute_option_params)
        format.html { redirect_to @product_attribute_option, notice: 'Product attribute option was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product_attribute_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_attribute_options/1
  # DELETE /product_attribute_options/1.json
  def destroy
    @product_attribute_option = ProductAttributeOption.find(params[:id])
    @product_attribute_option.destroy

    respond_to do |format|
      format.html { redirect_to product_attribute_options_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def product_attribute_option_params
      params.require(:product_attribute_option).permit(:deleted_at, :label, :position, :product_attribute_key_id, :value)
    end
end
