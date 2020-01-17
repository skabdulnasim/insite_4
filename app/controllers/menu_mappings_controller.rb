class MenuMappingsController < ApplicationController
  # GET /menu_mappings
  # GET /menu_mappings.json
  def index
    @menu_mappings = MenuMapping.all
    @days = MenuMapping.uniq.pluck(:day_id)
    @merge_sections = MenuMapping.uniq.pluck(:merge_section_id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @menu_mappings }
    end
  end

  # GET /menu_mappings/1
  # GET /menu_mappings/1.json
  def show
    @menu_mapping = MenuMapping.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @menu_mapping }
    end
  end

  # GET /menu_mappings/new
  # GET /menu_mappings/new.json
  def new
    @unit = current_user.unit
    @menu_mapping = MenuMapping.new
    @days = Day.all
    @sections = @unit.sections
    @menu_cards = @unit.menu_cards
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @menu_mapping }
    end
  end

  # GET /menu_mappings/1/edit
  def edit
    @menu_mapping = MenuMapping.find(params[:id])
    @unit = current_user.unit
    @days = Day.all
    @sections = @unit.sections
    @menu_cards = @unit.menu_cards
    @map_menus = MenuMapping.by_day(@menu_mapping.day_id).by_merge_section(@menu_mapping.merge_section_id)
    puts @map_menus.inspect
  end

  # POST /menu_mappings
  # POST /menu_mappings.json
  def create
    # @menu_mapping = MenuMapping.new(menu_mapping_params)
    params[:menu_mapping][:menu_card_id].each do |menu_card_id|
      if menu_card_id!=0
        params[:menu_mapping][:menu_card_id] = menu_card_id
        @menu_mapping = MenuMapping.new(params[:menu_mapping])
        @menu_mapping.save
      end
    end
    respond_to do |format|
      format.html { redirect_to menu_mappings_path, notice: 'Menu mapping was successfully created.' }
      format.json { render json: @menu_mapping, status: :created, location: @menu_mapping }
    end

    # respond_to do |format|
    #   if @menu_mapping.save
        # format.html { redirect_to @menu_mapping, notice: 'Menu mapping was successfully created.' }
        # format.json { render json: @menu_mapping, status: :created, location: @menu_mapping }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @menu_mapping.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /menu_mappings/1
  # PATCH/PUT /menu_mappings/1.json
  def update
    @menu_mapping = MenuMapping.find(params[:id])
    prev = MenuMapping.where('unit_id =? and day_id =? and merge_section_id =?', params['menu_mapping']['unit_id'],params['menu_mapping']['day_id'],params['menu_mapping']['merge_section_id'])
    prev.destroy_all if prev.present?
    params[:menu_mapping][:menu_card_id].each do |menu_card_id|
      if menu_card_id!=0
        params[:menu_mapping][:menu_card_id] = menu_card_id
        @menu_mapping = MenuMapping.new(params[:menu_mapping])
        @menu_mapping.save
      end
    end
    respond_to do |format|
      format.html { redirect_to @menu_mapping, notice: 'Menu mapping was successfully created.' }
      format.json { render json: @menu_mapping, status: :created, location: @menu_mapping }
    end
  end

  # DELETE /menu_mappings/1
  # DELETE /menu_mappings/1.json
  def destroy
    @menu_mapping = MenuMapping.find(params[:id])
    @menu_mapping.destroy

    respond_to do |format|
      format.html { redirect_to menu_mappings_url }
      format.json { head :no_content }
    end
  end

  def update_status
    @menu_mapping = MenuMapping.find(params[:menu_mapping_id])
    _status = @menu_mapping.status == "active" ? "inactive" : "active"
    @menu_mapping.update_attributes(:status => _status)

    respond_to do |format|
      format.json { render json: @menu_mapping }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def menu_mapping_params
      params.require(:menu_mapping).permit(:day_id, :menu_card_id, :merge_section_id, :section_id, :status, :unit_id)
    end
end
