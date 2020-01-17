class OutletTypesController < ApplicationController
  # GET /outlet_types
  # GET /outlet_types.json
  def index
    @outlet_types = OutletType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @outlet_types }
    end
  end

  # GET /outlet_types/1
  # GET /outlet_types/1.json
  def show
    @outlet_type = OutletType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @outlet_type }
    end
  end

  # GET /outlet_types/new
  # GET /outlet_types/new.json
  def new
    @outlet_type = OutletType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @outlet_type }
    end
  end

  # GET /outlet_types/1/edit
  def edit
    @outlet_type = OutletType.find(params[:id])
  end

  # POST /outlet_types
  # POST /outlet_types.json
  def create
    @outlet_type = OutletType.new(outlet_type_params)

    respond_to do |format|
      if @outlet_type.save
        format.html { redirect_to @outlet_type, notice: 'Outlet type was successfully created.' }
        format.json { render json: @outlet_type, status: :created, location: @outlet_type }
      else
        format.html { render action: "new" }
        format.json { render json: @outlet_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def save
    @name = params[:outlet_type]
    @outlet_type = OutletType.new
    @outlet_type[:name] = @name
    if @outlet_type.save
      @msg = "1"
    else
      @msg = "0"
    end
    
    respond_to do |format|
      format.json { render json: @msg }
    end
  end

  # PATCH/PUT /outlet_types/1
  # PATCH/PUT /outlet_types/1.json
  def update
    @outlet_type = OutletType.find(params[:id])

    respond_to do |format|
      if @outlet_type.update_attributes(outlet_type_params)
        format.html { redirect_to @outlet_type, notice: 'Outlet type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @outlet_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /outlet_types/1
  # DELETE /outlet_types/1.json
  def destroy
    @outlet_type = OutletType.find(params[:id])
    @outlet_type.destroy

    respond_to do |format|
      format.html { redirect_to outlet_types_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def outlet_type_params
      params.require(:outlet_type).permit(:name)
    end
end
