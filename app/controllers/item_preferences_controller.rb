class ItemPreferencesController < ApplicationController
  # GET /item_preferences
  # GET /item_preferences.json
  def index
    @item_preferences = ItemPreference.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @item_preferences }
    end
  end

  # GET /item_preferences/1
  # GET /item_preferences/1.json
  def show
    @item_preference = ItemPreference.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item_preference }
    end
  end

  # GET /item_preferences/new
  # GET /item_preferences/new.json
  def new
    @item_preference = ItemPreference.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item_preference }
    end
  end

  # GET /item_preferences/1/edit
  def edit
    @item_preference = ItemPreference.find(params[:id])
  end

  # POST /item_preferences
  # POST /item_preferences.json
  def create
    @item_preference = ItemPreference.new(item_preference_params)

    respond_to do |format|
      if @item_preference.save and CategoryItemPreference.save_category_item_preference(@item_preference.id, params['menu_category_ids']) 
        format.html { redirect_to @item_preference, notice: 'Item preference was successfully created.' }
        format.json { render json: @item_preference, status: :created, location: @item_preference }
      else
        format.html { render action: "new" }
        format.json { render json: @item_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /item_preferences/1
  # PATCH/PUT /item_preferences/1.json
  def update
    @item_preference = ItemPreference.find(params[:id])

    respond_to do |format|
      if @item_preference.update_attributes(item_preference_params) and CategoryItemPreference.save_category_item_preference(@item_preference.id, params['menu_category_ids'])
        format.html { redirect_to @item_preference, notice: 'Item preference was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @item_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /item_preferences/1
  # DELETE /item_preferences/1.json
  def destroy
    @item_preference = ItemPreference.find(params[:id])
    @item_preference.destroy

    respond_to do |format|
      format.html { redirect_to item_preferences_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def item_preference_params
      params.require(:item_preference).permit(:preference)
    end
end
