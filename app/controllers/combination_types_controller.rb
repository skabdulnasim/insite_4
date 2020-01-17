class CombinationTypesController < ApplicationController
  # GET /combination_types
  # GET /combination_types.json
  load_and_authorize_resource
  def index
    @combination_types = CombinationType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @combination_types }
    end
  end

  # GET /combination_types/1
  # GET /combination_types/1.json
  def show
    @combination_type = CombinationType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @combination_type }
    end
  end

  # GET /combination_types/new
  # GET /combination_types/new.json
  def new
    @combination_type = CombinationType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @combination_type }
    end
  end

  # GET /combination_types/1/edit
  def edit
    @combination_type = CombinationType.find(params[:id])
  end

  # POST /combination_types
  # POST /combination_types.json
  def create
    @combination_type = CombinationType.new(params[:combination_type])

    respond_to do |format|
      if @combination_type.save
        format.html { redirect_to menu_cards_manage_settings_path, notice: 'Combination type was successfully created.' }
        format.json { render json: @combination_type, status: :created, location: @combination_type }
      else
        format.html { redirect_to menu_cards_manage_settings_path, notice: 'Combination type was not created.' }
        format.json { render json: @combination_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /combination_types/1
  # PUT /combination_types/1.json
  def update
    @combination_type = CombinationType.find(params[:id])

    respond_to do |format|
      if @combination_type.update_attributes(params[:combination_type])
        format.html { redirect_to @combination_type, notice: 'Combination type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @combination_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /combination_types/1
  # DELETE /combination_types/1.json
  def destroy
    @combination_type = CombinationType.find(params[:id])
    @combination_type.destroy

    respond_to do |format|
      format.html { redirect_to combination_types_url }
      format.json { head :no_content }
    end
  end
end
