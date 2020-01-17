class OtpsController < ApplicationController
  # GET /otps
  # GET /otps.json
  def index
    @otps = Otp.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @otps }
    end
  end

  # GET /otps/1
  # GET /otps/1.json
  def show
    @otp = Otp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @otp }
    end
  end

  # GET /otps/new
  # GET /otps/new.json
  def new
    @otp = Otp.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @otp }
    end
  end

  # GET /otps/1/edit
  def edit
    @otp = Otp.find(params[:id])
  end

  # POST /otps
  # POST /otps.json
  def create
    @otp = Otp.new(otp_params)

    respond_to do |format|
      if @otp.save
        format.html { redirect_to @otp, notice: 'Otp was successfully created.' }
        format.json { render json: @otp, status: :created, location: @otp }
      else
        format.html { render action: "new" }
        format.json { render json: @otp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /otps/1
  # PATCH/PUT /otps/1.json
  def update
    @otp = Otp.find(params[:id])

    respond_to do |format|
      if @otp.update_attributes(otp_params)
        format.html { redirect_to @otp, notice: 'Otp was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @otp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /otps/1
  # DELETE /otps/1.json
  def destroy
    @otp = Otp.find(params[:id])
    @otp.destroy

    respond_to do |format|
      format.html { redirect_to otps_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def otp_params
      params.require(:otp).permit(:otp, :phone_number, :verified)
    end
end
