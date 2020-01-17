class TablesController < ApplicationController
  load_and_authorize_resource :except => [:change_table_state,:swap_table,:get_tables]
  layout "material"

  before_filter :set_module_details
  # GET /tables
  # GET /tables.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/tables.json', "Get all tables of a outlet"
  param :unit_id, String, :desc => "Unit ID (Must Required for Android)", :required => false
  param :section_id, String, :desc => "Section ID (Optional)", :required => false
  param :table_state_id, String, :desc => "Table state ID (Optional)", :required => false
  error :code => 401, :desc => "Unauthorized"
  description "Get all tables of all outlets (Filter by section and table state option is also available)"
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def index
    _current_outlet = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    _unit = Unit.find(_current_outlet)
    @unit_tables = Table.unit_tables(_current_outlet).enabled.non_trashed
    @unit_tables = @unit_tables.set_section(params[:section_id]) if params[:section_id].present?
    @unit_tables = @unit_tables.set_state(params[:table_state_id]) if params[:table_state_id].present?
    @sections = _unit.sections
    @table = Table.new
    @unit_types   = Unittype.where(:store_creatability => "1")
    @table_states = TableState.all
    @table_types  = TableType.all
    @leaf_units = BranchManagement::get_leaf_units()
    @sections = Section.where(:unit_id => current_user.unit_id)    
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => {:unit => _unit.as_json(:include => :unit_detail),
                                      :tables => @unit_tables.as_json(:include => :chairs) }}
    end
  end

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/tables/:id', "Show a table details"
  param :id, :number, :desc => "Table ID", :required => true
  error :code => 401, :desc => "Unauthorized"
  description "Show a table details"
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def show
    @table = Table.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @table }
    end
  end

  # GET /tables/new
  # GET /tables/new.json
  def new
    #@current_user_unit_id = current_user.unit_id
    @table = Table.new
    @unit_types   = Unittype.where(:store_creatability => "1")
    @table_states = TableState.all
    @table_types  = TableType.all
    @leaf_units = BranchManagement::get_leaf_units()
    @sections = Section.where(:unit_id => current_user.unit_id)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @table }
    end
  end

  # GET /tables/1/edit
  def edit
    @table = Table.find(params[:id])
    @unit_types   = Unittype.where(:store_creatability => "1")
    @table_states = TableState.all
    @table_types  = TableType.all
    @leaf_units = BranchManagement::get_leaf_units()
    @sections = Section.where(:unit_id => current_user.unit_id)
  end

  # POST /tables
  # POST /tables.json
  def create
    @table = Table.new(params[:table])
    respond_to do |format|
      if @table.save
        format.html { redirect_to tables_path, notice: 'Table was successfully created.' }
        format.json { render json: @table, status: :created, location: @table }
      else
        format.html { render action: "new" }
        format.json { render json: @table.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tables/1
  # PUT /tables/1.json
  def update
    @table = Table.find(params[:id])

    respond_to do |format|
      if @table.update_attributes(params[:table])
        format.html { redirect_to tables_path, notice: 'Table was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @table.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tables/1
  # DELETE /tables/1.json
  def destroy
    @table = Table.find(params[:id])
    @table.destroy

    respond_to do |format|
      format.html { redirect_to tables_url }
      format.json { head :no_content }
    end
  end

  def manage_settings
    @table_states = TableState.all
    @table_state = TableState.new
    @table_types = TableType.all
    @table_type = TableType.new
  end

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :POST, '/tables/change_table_state.json', "Change a table status"
    error :code => 401, :desc => "Unauthorized"
    param :table_id, String, :desc => "Table ID", :required => true
    param :user_id, String, :desc => "User ID", :required => true
    param :unit_id, String, :desc => "Outlet ID", :required => true
    param :table_state_id, String, :desc => "State ID, to which you want to change the table state", :required => true
    description "Change the table state of an outlet to : Empty, Occupied, Served, Reserved, Not Settled, Out of Order"
    formats ['json']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def change_table_state
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        @status_log = Table.update_table_state(params[:table_state_id],params[:unit_id],params[:table_id],params[:user_id],params[:device_id])
      end
      respond_to do |format|
        format.json { render json: @status_log }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: [{:error => e.message.to_s}] }
      end
    end
  end

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :POST, '/tables/swap_table.json', "Swap table orders"
    error :code => 401, :desc => "Unauthorized"
    param :old_table_id, String, :desc => "Old Table ID", :required => true
    param :new_table_id, String, :desc => "New Table ID", :required => true
    param :unit_id, String, :desc => "Unit ID", :required => true
    param :user_id, String, :desc => "User ID", :required => true
    param :order_ids, String, :desc => "Order IDs is JSON formats, which will be swapped to new table, [{'order_id':'3'},{'order_id':'4'},{'order_id':'5'}]", :required => true
    description "Transfer orders from one table to another, (Table SWAP)."
    formats ['json']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def swap_table
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        _order_ids = JSON.parse(params[:order_ids])
        _old_table = Table.find(params[:old_table_id])
        _new_table = Table.find(params[:new_table_id])
        Table.swap_table_orders _order_ids, _new_table, _old_table, params[:device_id], params[:user_id], params[:unit_id]
      end
    rescue Exception => @error
      Rscratch::Exception.log @error,request
    end
  end

  def get_tables
    @tables = Table.get_status(params[:section_id],params[:table_state_id])   #where(:section_id => params[:section_id],:table_state_id => params[:table_state_id])
    respond_to do |format|
      format.json { render json: @tables }
    end
  end

  private
  def set_module_details
    @module_id = "tables"
    @module_title = "Tables"
  end
end
