class ProductReligionsController < ApplicationController
  # GET /product_religions
  # GET /product_religions.json
  def index
    @product_religions = ProductReligion.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @product_religions }
    end
  end

  # GET /product_religions/1
  # GET /product_religions/1.json
  def show
    @product_religion = ProductReligion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_religion }
    end
  end

  # GET /product_religions/new
  # GET /product_religions/new.json
  def new
    @product_religion = ProductReligion.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product_religion }
    end
  end

  # GET /product_religions/1/edit
  def edit
    @product_religion = ProductReligion.find(params[:id])
  end

  # POST /product_religions
  # POST /product_religions.json
  def create
    @product_religion = ProductReligion.new(product_religion_params)

    respond_to do |format|
      if @product_religion.save
        format.html { redirect_to @product_religion, notice: 'Product religion was successfully created.' }
        format.json { render json: @product_religion, status: :created, location: @product_religion }
      else
        format.html { render action: "new" }
        format.json { render json: @product_religion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_religions/1
  # PATCH/PUT /product_religions/1.json
  def update
    @product_religion = ProductReligion.find(params[:id])

    respond_to do |format|
      if @product_religion.update_attributes(product_religion_params)
        format.html { redirect_to @product_religion, notice: 'Product religion was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product_religion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_religions/1
  # DELETE /product_religions/1.json
  def destroy
    @product_religion = ProductReligion.find(params[:id])
    @product_religion.destroy

    respond_to do |format|
      format.html { redirect_to product_religions_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def product_religion_params
      params.require(:product_religion).permit(:name)
    end
end
