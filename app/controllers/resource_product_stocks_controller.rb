class ResourceProductStocksController < ApplicationController
  # GET /resource_product_stocks
  # GET /resource_product_stocks.json
  def index
    @resource_product_stocks = ResourceProductStock.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resource_product_stocks }
    end
  end

  # GET /resource_product_stocks/1
  # GET /resource_product_stocks/1.json
  def show
    @resource_product_stock = ResourceProductStock.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource_product_stock }
    end
  end

  # GET /resource_product_stocks/new
  # GET /resource_product_stocks/new.json
  def new
    @resource_product_stock = ResourceProductStock.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource_product_stock }
    end
  end

  # GET /resource_product_stocks/1/edit
  def edit
    @resource_product_stock = ResourceProductStock.find(params[:id])
  end

  # POST /resource_product_stocks
  # POST /resource_product_stocks.json
  def create
    @resource_product_stock = ResourceProductStock.new(resource_product_stock_params)

    respond_to do |format|
      if @resource_product_stock.save
        format.html { redirect_to @resource_product_stock, notice: 'Resource product stock was successfully created.' }
        format.json { render json: @resource_product_stock, status: :created, location: @resource_product_stock }
      else
        format.html { render action: "new" }
        format.json { render json: @resource_product_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resource_product_stocks/1
  # PATCH/PUT /resource_product_stocks/1.json
  def update
    @resource_product_stock = ResourceProductStock.find(params[:id])

    respond_to do |format|
      if @resource_product_stock.update_attributes(resource_product_stock_params)
        format.html { redirect_to @resource_product_stock, notice: 'Resource product stock was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource_product_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource_product_stocks/1
  # DELETE /resource_product_stocks/1.json
  def destroy
    @resource_product_stock = ResourceProductStock.find(params[:id])
    @resource_product_stock.destroy

    respond_to do |format|
      format.html { redirect_to resource_product_stocks_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def resource_product_stock_params
      params.require(:resource_product_stock).permit(:product_id, :recorded_at, :resource_id, :stock, :user_id)
    end
end
