class TaxClassesController < ApplicationController
  # GET /tax_classes
  # GET /tax_classes.json
  load_and_authorize_resource
  
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/tax_classes.json', "Get all taxes"
  error :code => 401, :desc => "Unauthorized"
  description "Url : http://lazeez.stewot.com/tax_classes.json?device_id=YOTTO05" 
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def index
    @tax_classes = TaxClass.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tax_classes }
    end
  end

  # GET /tax_classes/1
  # GET /tax_classes/1.json
  def show
    @tax_class = TaxClass.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tax_class }
    end
  end

  # GET /tax_classes/new
  # GET /tax_classes/new.json
  def new
    @tax_class = TaxClass.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tax_class }
      format.js
    end
  end

  # GET /tax_classes/1/edit
  def edit
    @tax_class = TaxClass.find(params[:id])
  end

  # POST /tax_classes
  # POST /tax_classes.json
  def create
    @tax_class = TaxClass.new(params[:tax_class])
    respond_to do |format|
      if @tax_class.save
        format.html { redirect_to products_settings_path, notice: 'Tax class was successfully created.' }
        format.json { render json: @tax_class, status: :created, location: @tax_class }
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @tax_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tax_classes/1
  # PUT /tax_classes/1.json
  def update
    @tax_class = TaxClass.find(params[:id])

    respond_to do |format|
      if @tax_class.update_attributes(params[:tax_class])
        format.html { redirect_to products_settings_path, notice: 'Tax class was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: "edit" }
        format.json { render json: @tax_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tax_classes/1
  # DELETE /tax_classes/1.json
  def destroy
    @tax_class = TaxClass.find(params[:id])
    @tax_class.destroy

    respond_to do |format|
      format.html { redirect_to products_settings_url, notice: 'Tax class was successfully deleted. '}
      format.json { head :no_content }
      format.js
    end
  end
end
