class AttributesController < ApplicationController
  load_and_authorize_resource
  
  layout "material"
  before_filter :set_module_details  

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/attributes.json', "Get all attributes with term attributes. like size = half, full flavour = choco, vanila"
  error :code => 401, :desc => "Unauthorized"
  description "URL : http://lazeez.stewot.com/attributes.json?device_id=YOTTO05" 
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  # GET /attributes
  # GET /attributes.json
  def index
    @attributes = Attribute.all
    @attribute = Attribute.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @attributes.to_json(:include => :term_attributes) }
    end
  end

  # GET /attributes/1
  # GET /attributes/1.json
  def show
    @attribute = Attribute.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @attribute }
    end
  end

  # GET /attributes/new
  # GET /attributes/new.json
  def new
    @attribute = Attribute.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @attribute }
    end
  end

  # GET /attributes/1/edit
  def edit
    @attribute = Attribute.find(params[:id])
  end

  # POST /attributes
  # POST /attributes.json
  def create
    @attribute = Attribute.new(params[:attribute])

    respond_to do |format|
      if @attribute.save
        format.html { redirect_to attributes_path, notice: 'Attribute was successfully created.' }
        format.json { render json: @attribute, status: :created, location: @attribute }
      else
        format.html { render action: "index" }
        format.json { render json: @attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /attributes/1
  # PUT /attributes/1.json
  def update
    @attribute = Attribute.find(params[:id])

    respond_to do |format|
      if @attribute.update_attributes(params[:attribute])
        format.html { redirect_to attributes_url, notice: 'Attribute was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attributes/1
  # DELETE /attributes/1.json
  def destroy
    @attribute = Attribute.find(params[:id])
    @attribute.destroy

    respond_to do |format|
      format.html { redirect_to attributes_url }
      format.json { head :no_content }
    end
  end
  private

  def set_module_details
    @module_id = "products"
    @module_title = "Products"
  end  
end
