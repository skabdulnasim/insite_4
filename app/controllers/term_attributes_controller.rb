class TermAttributesController < ApplicationController
  load_and_authorize_resource
  
  layout "material"
  before_filter :set_module_details  
  
  # GET /term_attributes
  # GET /term_attributes.json
  def index
    @term_attribute = TermAttribute.new
    @attribute = Attribute.find(params[:id])
    if params[:id]
      @term_attributes = TermAttribute.where(:attribute_id => params[:id])
    end 

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @term_attributes }
    end
  end

  def get_terms
    @id = params[:id]
    @type_prio = TermAttribute.where("attribute_id" => @id)
        
    respond_to do |format|
      format.json { render :json => @type_prio}
    end
  end
    
  # GET /term_attributes/1
  # GET /term_attributes/1.json
  def show
    @term_attribute = TermAttribute.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @term_attribute }
    end
  end

  # GET /term_attributes/new
  # GET /term_attributes/new.json
  def new
    @term_attribute = TermAttribute.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @term_attribute }
    end
  end

  # GET /term_attributes/1/edit
  def edit
    @term_attribute = TermAttribute.find(params[:id])
  end

  # POST /term_attributes
  # POST /term_attributes.json
  def create
    @term_attribute = TermAttribute.new(params[:term_attribute])

    respond_to do |format|
      if @term_attribute.save
        format.html { redirect_to attributes_path, notice: 'Term attribute was successfully created.' }
        format.json { render json: @term_attribute, status: :created, location: @term_attribute }
      else
        format.html { render action: "index" }
        format.json { render json: @term_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /term_attributes/1
  # PUT /term_attributes/1.json
  def update
    @term_attribute = TermAttribute.find(params[:id])

    respond_to do |format|
      if @term_attribute.update_attributes(params[:term_attribute])
        format.html { redirect_to @term_attribute, notice: 'Term attribute was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "i" }
        format.json { render json: @term_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /term_attributes/1
  # DELETE /term_attributes/1.json
  def destroy
    @term_attribute = TermAttribute.find(params[:id])
    @term_attribute.destroy

    respond_to do |format|
      format.html { redirect_to term_attributes_url }
      format.json { head :no_content }
    end
  end
  private

  def set_module_details
    @module_id = "products"
    @module_title = "Products"
  end  
end
