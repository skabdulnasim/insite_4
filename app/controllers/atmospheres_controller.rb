class AtmospheresController < ApplicationController
  # GET /atmospheres
  # GET /atmospheres.json
  load_and_authorize_resource :except => [ :save, :drop ]
  def index
    @atmospheres = Atmosphere.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @atmospheres }
    end
  end

  # GET /atmospheres/1
  # GET /atmospheres/1.json
  def show
    @atmosphere = Atmosphere.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @atmosphere }
    end
  end

  # GET /atmospheres/new
  # GET /atmospheres/new.json
  def new
    @atmosphere = Atmosphere.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @atmosphere }
    end
  end

  def save
    @name = params[:form_of_payment]
    @meth = params[:action]
    @atmosphere = Atmosphere.new
    @atmosphere[:name] = @name
    if @atmosphere.save
      @msg = "1"
    else
      @msg = "0"
    end
    
    respond_to do |format|
      format.json { render json: @msg }
    end
  end
  
  def drop
    @atmosphere = Atmosphere.find(params[:id])
    @atmosphere.destroy
    if @atmosphere.destroy
      @msg = "1"
    else
      @msg = "0"
    end
    
    respond_to do |format|
      format.json { render json: @msg }
    end
  end

  # GET /atmospheres/1/edit
  def edit
    @atmosphere = Atmosphere.find(params[:id])
  end

  # POST /atmospheres
  # POST /atmospheres.json
  def create
    @atmosphere = Atmosphere.new(params[:atmosphere])

    respond_to do |format|
      if @atmosphere.save
        format.html { redirect_to @atmosphere, notice: 'Atmosphere was successfully created.' }
        format.json { render json: @atmosphere, status: :created, location: @atmosphere }
      else
        format.html { render action: "new" }
        format.json { render json: @atmosphere.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /atmospheres/1
  # PUT /atmospheres/1.json
  def update
    @atmosphere = Atmosphere.find(params[:id])

    respond_to do |format|
      if @atmosphere.update_attributes(params[:atmosphere])
        format.html { redirect_to @atmosphere, notice: 'Atmosphere was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @atmosphere.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /atmospheres/1
  # DELETE /atmospheres/1.json
  def destroy
    @atmosphere = Atmosphere.find(params[:id])
    @atmosphere.destroy

    respond_to do |format|
      format.html { redirect_to atmospheres_url }
      format.json { head :no_content }
    end
  end
end
