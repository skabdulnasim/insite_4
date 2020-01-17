class CustomerProfilesController < ApplicationController
  # GET /customer_profiles
  # GET /customer_profiles.json
  def index
    @customer_profiles = CustomerProfile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @customer_profiles }
    end
  end

  # GET /customer_profiles/1
  # GET /customer_profiles/1.json
  def show
    @customer_profile = CustomerProfile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @customer_profile }
    end
  end

  # GET /customer_profiles/new
  # GET /customer_profiles/new.json
  def new
    @customer_profile = CustomerProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @customer_profile }
    end
  end

  # GET /customer_profiles/1/edit
  def edit
    @customer_profile = CustomerProfile.find(params[:id])
  end

  # POST /customer_profiles
  # POST /customer_profiles.json
  def create
    @customer_profile = CustomerProfile.new(customer_profile_params)

    respond_to do |format|
      if @customer_profile.save
        format.html { redirect_to @customer_profile, notice: 'Customer profile was successfully created.' }
        format.json { render json: @customer_profile, status: :created, location: @customer_profile }
      else
        format.html { render action: "new" }
        format.json { render json: @customer_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customer_profiles/1
  # PATCH/PUT /customer_profiles/1.json
  def update
    @customer_profile = CustomerProfile.find(params[:id])

    respond_to do |format|
      if @customer_profile.update_attributes(customer_profile_params)
        format.html { redirect_to @customer_profile, notice: 'Customer profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @customer_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_profiles/1
  # DELETE /customer_profiles/1.json
  def destroy
    @customer_profile = CustomerProfile.find(params[:id])
    @customer_profile.destroy

    respond_to do |format|
      format.html { redirect_to customer_profiles_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def customer_profile_params
      params.require(:customer_profile).permit(:address, :age, :anniversary, :contact_no, :customer_name, :dob, :firstname, :gender, :lastname)
    end
end
