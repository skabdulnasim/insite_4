class DenominationsController < ApplicationController
  # GET /denominations
  # GET /denominations.json
  def index
    @denominations = Denomination.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @denominations }
    end
  end

  # GET /denominations/1
  # GET /denominations/1.json
  def show
    @denomination = Denomination.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @denomination }
    end
  end

  # GET /denominations/new
  # GET /denominations/new.json
  def new
    @denomination = Denomination.new
    @countries = Country.all
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @denomination }
    end
  end

  # GET /denominations/1/edit
  def edit
    @denomination = Denomination.find(params[:id])
    @countries = Country.all
  end

  # POST /denominations
  # POST /denominations.json
  def create
    @denomination = Denomination.new(denomination_params)

    respond_to do |format|
      if @denomination.save
        format.html { redirect_to @denomination, notice: 'Denomination was successfully created.' }
        format.json { render json: @denomination, status: :created, location: @denomination }
      else
        format.html { render action: "new" }
        format.json { render json: @denomination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /denominations/1
  # PATCH/PUT /denominations/1.json
  def update
    @denomination = Denomination.find(params[:id])

    respond_to do |format|
      if @denomination.update_attributes(denomination_params)
        format.html { redirect_to @denomination, notice: 'Denomination was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @denomination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /denominations/1
  # DELETE /denominations/1.json
  def destroy
    @denomination = Denomination.find(params[:id])
    @denomination.destroy

    respond_to do |format|
      format.html { redirect_to denominations_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def denomination_params
      params.require(:denomination).permit(:country_id, :name, :value, :image)
    end
end
