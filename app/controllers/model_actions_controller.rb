class ModelActionsController < ApplicationController
  # GET /model_actions
  # GET /model_actions.json
  def index
    ## this block of code is used to save master model name into public schema and this code block should be moved to some secure module please don't change anything
    ActiveRecord::Base.connection.tables.map do |model|
      model_name =  model.capitalize.singularize.camelize
      MasterModel.create(:name=>model_name,:status=>"active") unless MasterModel.where("name=?",model_name).present?
    end
    #################

    @model_actions = ModelAction.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @model_actions }
    end
  end

  # GET /model_actions/1
  # GET /model_actions/1.json
  def show
    @model_action = ModelAction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @model_action }
    end
  end

  # GET /model_actions/new
  # GET /model_actions/new.json
  def new
    
    @model_action = ModelAction.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @model_action }
    end
  end

  # GET /model_actions/1/edit
  def edit
    @model_action = ModelAction.find(params[:id])
  end

  # POST /model_actions
  # POST /model_actions.json
  def create
    puts "new parameters #{params}"
    params[:model_action][:name] = params[:model_action][:name].downcase
    @model_action = ModelAction.new(params[:model_action])

    respond_to do |format|
      if @model_action.save
        format.html { redirect_to model_actions_path, notice: 'Model action was successfully created.' }
        format.json { render json: @model_action, status: :created, location: @model_action }
      else
        format.html { render action: "new" }
        format.json { render json: @model_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /model_actions/1
  # PATCH/PUT /model_actions/1.json
  def update
    puts "update parameters #{params[:model_action]}"
    @model_action = ModelAction.find(params[:id])
    params[:model_action][:name] = params[:model_action][:name].downcase
    respond_to do |format|
      if @model_action.update_attributes(model_action_params)
        if params[:model_action][:reason_codes_attributes].present?
          params[:model_action][:reason_codes_attributes].each do |reason,attr|
            if attr[:id].present?
              reason_code = ReasonCode.find(attr[:id])
              reason_code.update_attributes(attr)
            else
              ReasonCode.create(:model_action_id=>@model_action.id, :reason=>attr[:reason],:stock_adjustment=>attr[:stock_adjustment])
            end
          end
        end
        format.html { redirect_to model_actions_path, notice: 'Model action was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @model_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /model_actions/1
  # DELETE /model_actions/1.json
  def destroy
    @model_action = ModelAction.find(params[:id])
    @model_action.destroy

    respond_to do |format|
      format.html { redirect_to model_actions_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def model_action_params
      params.require(:model_action).permit(:master_model_id, :name, :status)
    end
end
