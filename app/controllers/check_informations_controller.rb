class CheckInformationsController < ApplicationController

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  # GET /check_informations
  # GET /check_informations.json
  def index
    @check_informations = CheckInformation.order("id desc")
    smart_listing_create :smartlist_check_infos, @check_informations, partial: "check_informations/smartlist_check_infos"
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @check_informations }
    end
  end

  # GET /check_informations/1
  # GET /check_informations/1.json
  def show
    @check_information = CheckInformation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @check_information }
    end
  end

  # GET /check_informations/new
  # GET /check_informations/new.json
  def new
    @check_information = CheckInformation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @check_information }
    end
  end

  # GET /check_informations/1/edit
  def edit
    @check_information = CheckInformation.find(params[:id])
  end

  # POST /check_informations
  # POST /check_informations.json
  def create
    @check_information = CheckInformation.new(check_information_params)

    respond_to do |format|
      if @check_information.save
        format.html { redirect_to @check_information, notice: 'Check information was successfully created.' }
        format.json { render json: @check_information, status: :created, location: @check_information }
      else
        format.html { render action: "new" }
        format.json { render json: @check_information.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /check_informations/1
  # PATCH/PUT /check_informations/1.json
  def update
    @check_information = CheckInformation.find(params[:id])

    respond_to do |format|
      if @check_information.update_attributes(check_information_params)
        format.html { redirect_to @check_information, notice: 'Check information was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @check_information.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /check_informations/1
  # DELETE /check_informations/1.json
  def destroy
    @check_information = CheckInformation.find(params[:id])
    @check_information.destroy

    respond_to do |format|
      format.html { redirect_to check_informations_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def check_information_params
      params.require(:check_information).permit(:check_in_datetime, :check_out_datetime, :reservation_id, :status)
    end
end
