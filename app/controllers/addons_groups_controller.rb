class AddonsGroupsController < ApplicationController

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  # GET /addons_groups
  # GET /addons_groups.json
  def index
    # @addons_groups = AddonsGroup.all
    @addons_groups = current_user.unit.addons_groups

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @addons_groups }
    end
  end

  # GET /addons_groups/1
  # GET /addons_groups/1.json
  def show
    @addons_group = AddonsGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @addons_group }
    end
  end

  # GET /addons_groups/new
  # GET /addons_groups/new.json
  def new
    @addons_group = AddonsGroup.new
    @sections = Section.unit_sections(current_user.unit.id)
    @products = Product.get_all
    @products = @products.filter_by_string(params[:name_filter]) if params[:name_filter].present?
    @products = @products.filter_by_product_id(params[:product_id_filter]) if params[:product_id_filter].present?

    smart_listing_create :products, @products, partial: "addons_groups/products_smartlist", default_sort: {id: "desc"}
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @addons_group }
      format.js
    end
  end

  # GET /addons_groups/1/edit
  def edit
    @addons_group = AddonsGroup.find(params[:id])
    @sections = Section.unit_sections(current_user.unit.id)
    @products = Product.get_all
    @products = @products.filter_by_string(params[:name_filter]) if params[:name_filter].present?
    @products = @products.filter_by_product_id(params[:product_id_filter]) if params[:product_id_filter].present?

    smart_listing_create :products, @products, partial: "addons_groups/products_smartlist", default_sort: {id: "desc"}
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @addons_group }
      format.js
    end
  end

  # POST /addons_groups
  # POST /addons_groups.json
  def create
    begin
      raise "Product must be allocated to addons group." unless params[:checked_product_ids].present?
      ActiveRecord::Base.transaction do
        @addons_group = AddonsGroup.new(params[:addons_group])

        respond_to do |format|
          if @addons_group.save
            # AddonsGroupProduct.save_addons_group_products(@addons_group.id, params['checked_product_ids']) if params[:checked_product_ids].present?
            prev = @addons_group.addons_group_products
            prev.destroy_all if prev.present?
            params[:checked_product_ids].each do |product_id|
              AddonsGroupProduct.create(:addons_group_id => @addons_group.id, :product_id => product_id, :price => params["price#{product_id}"], :ammount => params["ammount#{product_id}"], :product_unit_id => params["product_unit_id#{product_id}"]) 
              AddonsGroupProduct.update_all( "price=#{params["price#{product_id}"]}", "product_id=#{product_id} AND product_unit_id=#{params["product_unit_id#{product_id}"]} AND ammount=#{params["ammount#{product_id}"]}" )
              MenuProductCombination.update_all( "price=#{params["price#{product_id}"]}", "product_id=#{product_id} AND product_unit_id=#{params["product_unit_id#{product_id}"]} AND ammount=#{params["ammount#{product_id}"]}" )
            end
            format.html { redirect_to addons_groups_path, notice: 'Addons group was successfully created.' }
            format.json { render json: @addons_group, status: :created, location: @addons_group }
          else
            format.html { render action: "new" }
            format.json { render json: @addons_group.errors, status: :unprocessable_entity }
          end
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_addons_group_path, alert: e.message.to_s
    end
  end

  # PATCH/PUT /addons_groups/1
  # PATCH/PUT /addons_groups/1.json
  def update
    begin
      raise "Product must be allocated to addons group." unless params[:checked_product_ids].present?
      ActiveRecord::Base.transaction do
        @addons_group = AddonsGroup.find(params[:id])

        respond_to do |format|
          if @addons_group.update_attributes(params[:addons_group])
            # AddonsGroupProduct.save_addons_group_products(@addons_group.id, params['checked_product_ids']) if params[:checked_product_ids].present?
            prev = @addons_group.addons_group_products
            prev.destroy_all if prev.present?
            params[:checked_product_ids].each do |product_id|
              AddonsGroupProduct.create(:addons_group_id => @addons_group.id, :product_id => product_id, :price => params["price#{product_id}"], :ammount => params["ammount#{product_id}"], :product_unit_id => params["product_unit_id#{product_id}"]) 
              AddonsGroupProduct.update_all( "price=#{params["price#{product_id}"]}", "product_id=#{product_id} AND product_unit_id=#{params["product_unit_id#{product_id}"]} AND ammount=#{params["ammount#{product_id}"]} AND addons_group_id IN(SELECT id FROM addons_groups WHERE unit_id=#{@addons_group.unit_id})" )
              MenuProductCombination.update_all( "price=#{params["price#{product_id}"]}", "product_id=#{product_id} AND product_unit_id=#{params["product_unit_id#{product_id}"]} AND ammount=#{params["ammount#{product_id}"]} AND addons_group_id IN(SELECT id FROM addons_groups WHERE unit_id=#{@addons_group.unit_id})" )
              # _all_same_addons = AddonsGroupProduct.by_product_and_unit(product_id,params["product_unit_id#{product_id}"])
              # if _all_same_addons.present?
              #   _all_same_addons.each do |adn|
              #     adn.update_attributes()
              #   end
              # end
            end
            format.html { redirect_to addons_groups_path, notice: 'Addons group was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @addons_group.errors, status: :unprocessable_entity }
          end
        end
      end  
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_addons_group_path, alert: e.message.to_s
    end
  end

  # DELETE /addons_groups/1
  # DELETE /addons_groups/1.json
  def destroy
    @addons_group = AddonsGroup.find(params[:id])
    @addons_group.destroy

    respond_to do |format|
      format.html { redirect_to addons_groups_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def addons_group_params
      params.require(:addons_group).permit(:title, :unit_id)
    end
end
