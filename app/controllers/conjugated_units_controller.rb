class ConjugatedUnitsController < ApplicationController
  # GET /conjugated_units
  # GET /conjugated_units.json
  def index
    @conjugated_units = ConjugatedUnit.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @conjugated_units }
    end
  end

  # GET /conjugated_units/1
  # GET /conjugated_units/1.json
  def show
    @conjugated_unit = ConjugatedUnit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @conjugated_unit }
    end
  end

  # GET /conjugated_units/new
  # GET /conjugated_units/new.json
  def new
    @conjugated_unit = ConjugatedUnit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @conjugated_unit }
    end
  end

  # GET /conjugated_units/1/edit
  def edit
    @conjugated_unit = ConjugatedUnit.find(params[:id])
  end

  # POST /conjugated_units
  # POST /conjugated_units.json
  def create
    @conjugated_unit = ConjugatedUnit.new(conjugated_unit_params)

    respond_to do |format|
      if @conjugated_unit.save
        format.html { redirect_to @conjugated_unit, notice: 'Conjugated unit was successfully created.' }
        format.json { render json: @conjugated_unit, status: :created, location: @conjugated_unit }
      else
        format.html { render action: "new" }
        format.json { render json: @conjugated_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /conjugated_units/1
  # PATCH/PUT /conjugated_units/1.json
  def update
    @conjugated_unit = ConjugatedUnit.find(params[:id])

    respond_to do |format|
      if @conjugated_unit.update_attributes(conjugated_unit_params)
        format.html { redirect_to @conjugated_unit, notice: 'Conjugated unit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @conjugated_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /conjugated_units/1
  # DELETE /conjugated_units/1.json
  def destroy
    @conjugated_unit = ConjugatedUnit.find(params[:id])
    @conjugated_unit.destroy

    respond_to do |format|
      format.html { redirect_to conjugated_units_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def conjugated_unit_params
      params.require(:conjugated_unit).permit(:conjugated_id, :conjugated_name)
    end
end
