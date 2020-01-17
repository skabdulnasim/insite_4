class ProductMetaController < ApplicationController
  # GET /product_meta
  # GET /product_meta.json
  load_and_authorize_resource
  def index
    @product_meta = ProductMetum.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @product_meta }
    end
  end

  # GET /product_meta/1
  # GET /product_meta/1.json
  def show
    @product_metum = ProductMetum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_metum }
    end
  end

  # GET /product_meta/new
  # GET /product_meta/new.json
  def new
    @product_metum = ProductMetum.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product_metum }
    end
  end

  # GET /product_meta/1/edit
  def edit
    @product_metum = ProductMetum.find(params[:id])
  end

  # POST /product_meta
  # POST /product_meta.json
  def create
    @product_metum = ProductMetum.new(params[:product_metum])

    respond_to do |format|
      if @product_metum.save
        format.html { redirect_to @product_metum, notice: 'Product metum was successfully created.' }
        format.json { render json: @product_metum, status: :created, location: @product_metum }
      else
        format.html { render action: "new" }
        format.json { render json: @product_metum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /product_meta/1
  # PUT /product_meta/1.json
  def update
    @product_metum = ProductMetum.find(params[:id])

    respond_to do |format|
      if @product_metum.update_attributes(params[:product_metum])
        format.html { redirect_to @product_metum, notice: 'Product metum was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product_metum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_meta/1
  # DELETE /product_meta/1.json
  def destroy
    @product_metum = ProductMetum.find(params[:id])
    @product_metum.destroy

    respond_to do |format|
      format.html { redirect_to product_meta_url }
      format.json { head :no_content }
    end
  end
end
