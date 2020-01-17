class SlotsController < ApplicationController
  layout "material"
  
  before_filter :set_module_details
  # GET /slots
  # GET /slots.json
  def index
    @slots = Slot.by_unit(current_user.unit_id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @slots }
    end
  end

  # GET /slots/1
  # GET /slots/1.json
  def show
    @slot = Slot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @slot }
    end
  end

  # GET /slots/new
  # GET /slots/new.json
  def new
    @slot = Slot.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @slot }
    end
  end

  # GET /slots/1/edit
  def edit
    @slot = Slot.find(params[:id])
  end

  # POST /slots
  # POST /slots.json
  def create
    @slot = Slot.new(slot_params)

    respond_to do |format|
      if @slot.save
        format.html { redirect_to slots_url, notice: 'Slot was successfully created.' }
        format.json { render json: @slot, status: :created, location: @slot }
      else
        format.html { render action: "new" }
        format.json { render json: @slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /slots/1
  # PATCH/PUT /slots/1.json
  def update
    @slot = Slot.find(params[:id])

    respond_to do |format|
      if @slot.update_attributes(slot_params)
        format.html { redirect_to @slot, notice: 'Slot was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slots/1
  # DELETE /slots/1.json
  def destroy
    @slot = Slot.find(params[:id])
    @slot.destroy

    respond_to do |format|
      format.html { redirect_to slots_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def set_module_details
      @module_id = "slots"
      @module_title = "Slots"
    end

    def slot_params
      params.require(:slot).permit(:duration, :end_time, :start_time, :title, :unit_id, :status, :max_booking, :start_date, :end_date, :slot_type)
    end
end
