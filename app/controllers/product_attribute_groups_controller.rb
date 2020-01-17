class ProductAttributeGroupsController < ApplicationController
  # GET /product_attribute_groups
  # GET /product_attribute_groups.json
  def index
    @product_attribute_groups = ProductAttributeGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @product_attribute_groups }
    end
  end

  # GET /product_attribute_groups/1
  # GET /product_attribute_groups/1.json
  def show
    @product_attribute_group = ProductAttributeGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_attribute_group }
    end
  end

  # GET /product_attribute_groups/new
  # GET /product_attribute_groups/new.json
  def new
    @product_attribute_group = ProductAttributeGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product_attribute_group }
    end
  end

  # GET /product_attribute_groups/1/edit
  def edit
    @product_attribute_group = ProductAttributeGroup.find(params[:id])
  end

  # POST /product_attribute_groups
  # POST /product_attribute_groups.json
  def create
    @product_attribute_group = ProductAttributeGroup.new(product_attribute_group_params)

    respond_to do |format|
      if @product_attribute_group.save
        format.html { redirect_to @product_attribute_group, notice: 'Product attribute group was successfully created.' }
        format.json { render json: @product_attribute_group, status: :created, location: @product_attribute_group }
      else
        format.html { render action: "new" }
        format.json { render json: @product_attribute_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_attribute_groups/1
  # PATCH/PUT /product_attribute_groups/1.json
  def update
    @product_attribute_group = ProductAttributeGroup.find(params[:id])

    respond_to do |format|
      if @product_attribute_group.update_attributes(product_attribute_group_params)
        format.html { redirect_to @product_attribute_group, notice: 'Product attribute group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product_attribute_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_attribute_groups/1
  # DELETE /product_attribute_groups/1.json
  def destroy
    @product_attribute_group = ProductAttributeGroup.find(params[:id])
    @product_attribute_group.destroy

    respond_to do |format|
      format.html { redirect_to product_attribute_groups_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def product_attribute_group_params
      params.require(:product_attribute_group).permit(:deleted_at, :is_system_entity, :name, :position, :product_attribute_set)
    end
end
