class StoreRacksController < ApplicationController
  # GET /store_racks
  # GET /store_racks.json
  def index
    @store_racks = StoreRack.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @store_racks }
    end
  end

  # GET /store_racks/1
  # GET /store_racks/1.json
  def show
    @store_rack = StoreRack.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @store_rack }
    end
  end

  # GET /store_racks/new
  # GET /store_racks/new.json
  def new
    store = Store.find(params[:store_id])
    #2nd you build a new one

    @store_rack = store.store_racks.build
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @store_rack }
    end
  end

  # GET /store_racks/1/edit
  def edit
    @store_rack = StoreRack.find(params[:id])
  end

  # POST /store_racks
  # POST /store_racks.json
  def create
    store = Store.find(params[:store_id])
    @store_rack = store.store_racks.create(params[:store_rack])
    respond_to do |format|
      if @store_rack.save
        format.html { redirect_to store, notice: 'Store rack was successfully created.' }
        format.json { render json: @store_rack, status: :created, location: @store_rack }
      else
        format.html { render action: "new" }
        format.json { render json: @store_rack.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /store_racks/1
  # PATCH/PUT /store_racks/1.json
  def update
    @store_rack = StoreRack.find(params[:id])

    respond_to do |format|
      if @store_rack.update_attributes(store_rack_params)
        format.html { redirect_to @store_rack, notice: 'Store rack was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @store_rack.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /store_racks/1
  # DELETE /store_racks/1.json
  def destroy
    @store_rack = StoreRack.find(params[:id])
    @store_rack.destroy

    respond_to do |format|
      format.html { redirect_to store_racks_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def store_rack_params
      params.require(:store_rack).permit(:height, :name, :store, :width)
    end
end
