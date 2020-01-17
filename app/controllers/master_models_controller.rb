class MasterModelsController < ApplicationController
  # GET /master_models
  # GET /master_models.json
  def index
    @master_models = MasterModel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @master_models }
    end
  end

  # GET /master_models/1
  # GET /master_models/1.json
  def show
    @master_model = MasterModel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @master_model }
    end
  end

  # GET /master_models/new
  # GET /master_models/new.json
  def new
    @master_model = MasterModel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @master_model }
    end
  end

  # GET /master_models/1/edit
  def edit
    @master_model = MasterModel.find(params[:id])
  end

  # POST /master_models
  # POST /master_models.json
  def create
    @master_model = MasterModel.new(master_model_params)

    respond_to do |format|
      if @master_model.save
        format.html { redirect_to @master_model, notice: 'Master model was successfully created.' }
        format.json { render json: @master_model, status: :created, location: @master_model }
      else
        format.html { render action: "new" }
        format.json { render json: @master_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /master_models/1
  # PATCH/PUT /master_models/1.json
  def update
    @master_model = MasterModel.find(params[:id])

    respond_to do |format|
      if @master_model.update_attributes(master_model_params)
        format.html { redirect_to @master_model, notice: 'Master model was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @master_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /master_models/1
  # DELETE /master_models/1.json
  def destroy
    @master_model = MasterModel.find(params[:id])
    @master_model.destroy

    respond_to do |format|
      format.html { redirect_to master_models_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def master_model_params
      params.require(:master_model).permit(:name, :status)
    end
end
