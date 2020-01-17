class BinsController < ApplicationController
  # GET /bins
  # GET /bins.json
  def index
    store_rack = StoreRack.find(params[:store_rack_id])
    @bins = store_rack.bins
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bins }
    end
  end

  # GET /bins/1
  # GET /bins/1.json
  def show
    @bin = Bin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bin }
    end
  end

  # GET /bins/new
  # GET /bins/new.json
  def new
    store_rack = StoreRack.find(params[:store_rack_id])
    #2nd you build a new one

    @bin = store_rack.bins.build
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bin }
    end
  end

  # GET /bins/1/edit
  def edit
    @bin = Bin.find(params[:id])
  end

  # POST /bins
  # POST /bins.json
  def create
    store_rack = StoreRack.find(params[:store_rack_id])
    @bin = store_rack.bins.create(params[:bin])
    respond_to do |format|
      if @bin.save
        format.html { redirect_to @bin, notice: 'Bin was successfully created.' }
        format.json { render json: @bin, status: :created, location: @bin }
      else
        format.html { render action: "new" }
        format.json { render json: @bin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bins/1
  # PATCH/PUT /bins/1.json
  def update
    @bin = Bin.find(params[:id])

    respond_to do |format|
      if @bin.update_attributes(bin_params)
        format.html { redirect_to @bin, notice: 'Bin was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bins/1
  # DELETE /bins/1.json
  def destroy
    @bin = Bin.find(params[:id])
    @bin.destroy

    respond_to do |format|
      format.html { redirect_to bins_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def bin_params
      params.require(:bin).permit(:breadth, :height, :name, :row_no, :store_rack, :unique_identify_no, :width)
    end
end
