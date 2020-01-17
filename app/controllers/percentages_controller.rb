class PercentagesController < ApplicationController
  # GET /percentages
  # GET /percentages.json
  def index
    @percentages = Percentage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @percentages }
    end
  end

  # GET /percentages/1
  # GET /percentages/1.json
  def show
    @percentage = Percentage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @percentage }
    end
  end

  # GET /percentages/new
  # GET /percentages/new.json
  def new
    @percentage = Percentage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @percentage }
    end
  end

  # GET /percentages/1/edit
  def edit
    @percentage = Percentage.find(params[:id])
  end

  # POST /percentages
  # POST /percentages.json
  def create
    @percentage = Percentage.new(percentage_params)

    respond_to do |format|
      if @percentage.save
        format.html { redirect_to @percentage, notice: 'Percentage was successfully created.' }
        format.json { render json: @percentage, status: :created, location: @percentage }
      else
        format.html { render action: "new" }
        format.json { render json: @percentage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /percentages/1
  # PATCH/PUT /percentages/1.json
  def update
    @percentage = Percentage.find(params[:id])

    respond_to do |format|
      if @percentage.update_attributes(percentage_params)
        format.html { redirect_to @percentage, notice: 'Percentage was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @percentage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /percentages/1
  # DELETE /percentages/1.json
  def destroy
    @percentage = Percentage.find(params[:id])
    @percentage.destroy

    respond_to do |format|
      format.html { redirect_to percentages_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def percentage_params
      params.require(:percentage).permit(:name, :value)
    end
end
