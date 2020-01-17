class ComboItemsController < ApplicationController
  # GET /combo_items
  # GET /combo_items.json
  def index
    @combo_items = ComboItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @combo_items }
    end
  end

  # GET /combo_items/1
  # GET /combo_items/1.json
  def show
    @combo_item = ComboItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @combo_item }
    end
  end

  # GET /combo_items/new
  # GET /combo_items/new.json
  def new
    @combo_item = ComboItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @combo_item }
    end
  end

  # GET /combo_items/1/edit
  def edit
    @combo_item = ComboItem.find(params[:id])
  end

  # POST /combo_items
  # POST /combo_items.json
  def create
    @combo_item = ComboItem.new(combo_item_params)

    respond_to do |format|
      if @combo_item.save
        format.html { redirect_to @combo_item, notice: 'Combo item was successfully created.' }
        format.json { render json: @combo_item, status: :created, location: @combo_item }
      else
        format.html { render action: "new" }
        format.json { render json: @combo_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /combo_items/1
  # PATCH/PUT /combo_items/1.json
  def update
    @combo_item = ComboItem.find(params[:id])

    respond_to do |format|
      if @combo_item.update_attributes(combo_item_params)
        format.html { redirect_to @combo_item, notice: 'Combo item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @combo_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /combo_items/1
  # DELETE /combo_items/1.json
  def destroy
    @combo_item = ComboItem.find(params[:id])
    @combo_item.destroy

    respond_to do |format|
      format.html { redirect_to combo_items_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def combo_item_params
      params.require(:combo_item).permit(:color_id, :item_id, :menu_product_id, :mode, :sell_price, :sell_price_without_tax, :size_id, :tax_group_id)
    end
end
