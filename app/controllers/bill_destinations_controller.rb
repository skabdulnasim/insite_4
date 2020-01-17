class BillDestinationsController < ApplicationController
  # GET /bill_destinations
  # GET /bill_destinations.json
  def index
    @bill_destinations = BillDestination.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bill_destinations }
    end
  end

  # GET /bill_destinations/1
  # GET /bill_destinations/1.json
  def show
    @bill_destination = BillDestination.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bill_destination }
    end
  end

  # GET /bill_destinations/new
  # GET /bill_destinations/new.json
  def new
    @bill_destination = BillDestination.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bill_destination }
    end
  end

  # GET /bill_destinations/1/edit
  def edit
    @bill_destination = BillDestination.find(params[:id])
  end

  # POST /bill_destinations
  # POST /bill_destinations.json
  def create
    @bill_destination = BillDestination.new(bill_destination_params)

    respond_to do |format|
      if @bill_destination.save
        format.html { redirect_to @bill_destination, notice: 'Bill destination was successfully created.' }
        format.json { render json: @bill_destination, status: :created, location: @bill_destination }
      else
        format.html { render action: "new" }
        format.json { render json: @bill_destination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bill_destinations/1
  # PATCH/PUT /bill_destinations/1.json
  def update
    @bill_destination = BillDestination.find(params[:id])

    respond_to do |format|
      if @bill_destination.update_attributes(bill_destination_params)
        format.html { redirect_to @bill_destination, notice: 'Bill destination was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bill_destination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bill_destinations/1
  # DELETE /bill_destinations/1.json
  def destroy
    @bill_destination = BillDestination.find(params[:id])
    @bill_destination.destroy

    respond_to do |format|
      format.html { redirect_to bill_destinations_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def bill_destination_params
      params.require(:bill_destination).permit(:bill_footer, :bill_header, :name, :unit_id)
    end
end
