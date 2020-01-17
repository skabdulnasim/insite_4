class TableTypesController < ApplicationController
  load_and_authorize_resource
  # GET /table_types
  # GET /table_types.json
  def index
    @table_types = TableType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @table_types }
    end
  end

  # GET /table_types/1
  # GET /table_types/1.json
  def show
    @table_type = TableType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @table_type }
    end
  end

  # GET /table_types/new
  # GET /table_types/new.json
  def new
    @table_type = TableType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @table_type }
    end
  end

  # GET /table_types/1/edit
  def edit
    @table_type = TableType.find(params[:id])
  end

  # POST /table_types
  # POST /table_types.json
  def create
    @table_type = TableType.new(params[:table_type])

    respond_to do |format|
      if @table_type.save
        format.html { redirect_to manage_settings_tables_path, notice: 'Table type was successfully created.' }
        format.json { render json: @table_type, status: :created, location: @table_type }
      else
        format.html { render action: "new" }
        format.json { render json: @table_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /table_types/1
  # PUT /table_types/1.json
  def update
    @table_type = TableType.find(params[:id])

    respond_to do |format|
      if @table_type.update_attributes(params[:table_type])
        format.html { redirect_to manage_settings_tables_path, notice: 'Table type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @table_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /table_types/1
  # DELETE /table_types/1.json
  def destroy
    @table_type = TableType.find(params[:id])
    @table_type.destroy

    respond_to do |format|
      format.html { redirect_to manage_settings_tables_path }
      format.json { head :no_content }
    end
  end
end
