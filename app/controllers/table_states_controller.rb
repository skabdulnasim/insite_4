class TableStatesController < ApplicationController
  
  load_and_authorize_resource
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/table_states.json', "All table states"
  error :code => 401, :desc => "Unauthorized"
  description "List of all table states" 
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#  
  def index
    @table_states = TableState.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @table_states }
    end
  end

  # GET /table_states/1
  # GET /table_states/1.json
  def show
    @table_state = TableState.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @table_state }
    end
  end

  # GET /table_states/new
  # GET /table_states/new.json
  def new
    @table_state = TableState.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @table_state }
    end
  end

  # GET /table_states/1/edit
  def edit
    @table_state = TableState.find(params[:id])
  end

  # POST /table_states
  # POST /table_states.json
  def create
    @table_state = TableState.new(params[:table_state])

    respond_to do |format|
      if @table_state.save
        format.html { redirect_to manage_settings_tables_path, notice: 'Table state was successfully created.' }
        format.json { render json: @table_state, status: :created, location: @table_state }
      else
        format.html { render action: "new" }
        format.json { render json: @table_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /table_states/1
  # PUT /table_states/1.json
  def update
    @table_state = TableState.find(params[:id])

    respond_to do |format|
      if @table_state.update_attributes(params[:table_state])
        format.html { redirect_to manage_settings_tables_path, notice: 'Table state was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @table_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /table_states/1
  # DELETE /table_states/1.json
  def destroy
    @table_state = TableState.find(params[:id])
    @table_state.destroy

    respond_to do |format|
      format.html { redirect_to manage_settings_tables_path }
      format.json { head :no_content }
    end
  end
end
