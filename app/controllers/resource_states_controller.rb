class ResourceStatesController < ApplicationController
  # GET /resource_states
  # GET /resource_states.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/resource_states.json', "All table states"
  error :code => 401, :desc => "Unauthorized"
  description "List of all table states" 
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<# 
  def index
    @resource_states = ResourceState.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resource_states }
    end
  end

  # GET /resource_states/1
  # GET /resource_states/1.json
  def show
    @resource_state = ResourceState.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource_state }
    end
  end

  # GET /resource_states/new
  # GET /resource_states/new.json
  def new
    @resource_state = ResourceState.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource_state }
    end
  end

  # GET /resource_states/1/edit
  def edit
    @resource_state = ResourceState.find(params[:id])
  end

  # POST /resource_states
  # POST /resource_states.json
  def create
    @resource_state = ResourceState.new(resource_state_params)

    respond_to do |format|
      if @resource_state.save
        format.html { redirect_to @resource_state, notice: 'Resource state was successfully created.' }
        format.json { render json: @resource_state, status: :created, location: @resource_state }
      else
        format.html { render action: "new" }
        format.json { render json: @resource_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resource_states/1
  # PATCH/PUT /resource_states/1.json
  def update
    @resource_state = ResourceState.find(params[:id])

    respond_to do |format|
      if @resource_state.update_attributes(resource_state_params)
        format.html { redirect_to @resource_state, notice: 'Resource state was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource_states/1
  # DELETE /resource_states/1.json
  def destroy
    @resource_state = ResourceState.find(params[:id])
    @resource_state.destroy

    respond_to do |format|
      format.html { redirect_to resource_states_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def resource_state_params
      params.require(:resource_state).permit(:color_code, :name, :state_priority, :trash)
    end
end
