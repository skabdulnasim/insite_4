class CostCategoriesController < ApplicationController
  # GET /cost_categories
  # GET /cost_categories.json
  def index
    @cost_categories = CostCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cost_categories }
    end
  end

  # GET /cost_categories/1
  # GET /cost_categories/1.json
  def show
    @cost_category = CostCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cost_category }
    end
  end

  # GET /cost_categories/new
  # GET /cost_categories/new.json
  def new
    @cost_category = CostCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cost_category }
    end
  end

  # GET /cost_categories/1/edit
  def edit
    @cost_category = CostCategory.find(params[:id])
  end

  # POST /cost_categories
  # POST /cost_categories.json
  def create
    @cost_category = CostCategory.new(cost_category_params)

    respond_to do |format|
      if @cost_category.save
        format.html { redirect_to @cost_category, notice: 'Cost category was successfully created.' }
        format.json { render json: @cost_category, status: :created, location: @cost_category }
      else
        format.html { render action: "new" }
        format.json { render json: @cost_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cost_categories/1
  # PATCH/PUT /cost_categories/1.json
  def update
    @cost_category = CostCategory.find(params[:id])

    respond_to do |format|
      if @cost_category.update_attributes(cost_category_params)
        format.html { redirect_to @cost_category, notice: 'Cost category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cost_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cost_categories/1
  # DELETE /cost_categories/1.json
  def destroy
    @cost_category = CostCategory.find(params[:id])
    @cost_category.destroy

    respond_to do |format|
      format.html { redirect_to cost_categories_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def cost_category_params
      params.require(:cost_category).permit(:description, :name)
    end
end
