class AllergiesController < ApplicationController
  # GET /allergies
  # GET /allergies.json
  def index
    @allergies = Allergy.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @allergies }
    end
  end

  # GET /allergies/1
  # GET /allergies/1.json
  def show
    @allergy = Allergy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @allergy }
    end
  end

  # GET /allergies/new
  # GET /allergies/new.json
  def new
    @allergy = Allergy.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @allergy }
    end
  end

  # GET /allergies/1/edit
  def edit
    @allergy = Allergy.find(params[:id])
  end

  # POST /allergies
  # POST /allergies.json
  def create
    @allergy = Allergy.new(allergy_params)

    respond_to do |format|
      if @allergy.save
        format.html { redirect_to @allergy, notice: 'Allergy was successfully created.' }
        format.json { render json: @allergy, status: :created, location: @allergy }
      else
        format.html { render action: "new" }
        format.json { render json: @allergy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /allergies/1
  # PATCH/PUT /allergies/1.json
  def update
    @allergy = Allergy.find(params[:id])

    respond_to do |format|
      if @allergy.update_attributes(allergy_params)
        format.html { redirect_to @allergy, notice: 'Allergy was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @allergy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /allergies/1
  # DELETE /allergies/1.json
  def destroy
    @allergy = Allergy.find(params[:id])
    @allergy.destroy

    respond_to do |format|
      format.html { redirect_to allergies_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def allergy_params
      params.require(:allergy).permit(:name)
    end
end
