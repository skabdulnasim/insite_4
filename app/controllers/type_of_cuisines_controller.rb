class TypeOfCuisinesController < ApplicationController
  # GET /type_of_cuisines
  # GET /type_of_cuisines.json
  load_and_authorize_resource :except => [:save, :drop]
  def index
    @type_of_cuisines = TypeOfCuisine.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @type_of_cuisines }
    end
  end

  # GET /type_of_cuisines/1
  # GET /type_of_cuisines/1.json
  def show
    @type_of_cuisine = TypeOfCuisine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @type_of_cuisine }
    end
  end

  # GET /type_of_cuisines/new
  # GET /type_of_cuisines/new.json
  def new
    @type_of_cuisine = TypeOfCuisine.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @type_of_cuisine }
    end
  end
  
  def save
    @name = params[:form_of_payment]
    @type_of_cuisine = TypeOfCuisine.new
    @type_of_cuisine[:name] = @name
    if @type_of_cuisine.save
      @msg = "1"
    else
      @msg = "0"
    end
    
    respond_to do |format|
      format.json { render json: @msg }
    end
  end
  
  def drop
    @type_of_cuisine = TypeOfCuisine.find(params[:id])
    if @type_of_cuisine.destroy
      @msg = "1"
    else
      @msg = "0"
    end
    
    respond_to do |format|
      format.json { render json: @msg }
    end
  end
  
  # GET /type_of_cuisines/1/edit
  def edit
    @type_of_cuisine = TypeOfCuisine.find(params[:id])
  end

  # POST /type_of_cuisines
  # POST /type_of_cuisines.json
  def create
    @type_of_cuisine = TypeOfCuisine.new(params[:type_of_cuisine])

    respond_to do |format|
      if @type_of_cuisine.save
        format.html { redirect_to @type_of_cuisine, notice: 'Type of cuisine was successfully created.' }
        format.json { render json: @type_of_cuisine, status: :created, location: @type_of_cuisine }
      else
        format.html { render action: "new" }
        format.json { render json: @type_of_cuisine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /type_of_cuisines/1
  # PUT /type_of_cuisines/1.json
  def update
    @type_of_cuisine = TypeOfCuisine.find(params[:id])

    respond_to do |format|
      if @type_of_cuisine.update_attributes(params[:type_of_cuisine])
        format.html { redirect_to @type_of_cuisine, notice: 'Type of cuisine was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @type_of_cuisine.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /type_of_cuisines/1
  # DELETE /type_of_cuisines/1.json
  def destroy
    @type_of_cuisine = TypeOfCuisine.find(params[:id])
    @type_of_cuisine.destroy

    respond_to do |format|
      format.html { redirect_to type_of_cuisines_url }
      format.json { head :no_content }
    end
  end
end
