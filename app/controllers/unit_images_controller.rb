class UnitImagesController < ApplicationController
  # GET /unit_images
  # GET /unit_images.json
  def index
    @unit_images = UnitImage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @unit_images }
    end
  end

  # GET /unit_images/1
  # GET /unit_images/1.json
  def show
    @unit_image = UnitImage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @unit_image }
    end
  end

  # GET /unit_images/new
  # GET /unit_images/new.json
  def new
    @unit_image = UnitImage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @unit_image }
    end
  end

  # GET /unit_images/1/edit
  def edit
    @unit_image = UnitImage.find(params[:id])
  end

  # POST /unit_images
  # POST /unit_images.json
  def create
    @unit_image = UnitImage.new(unit_image_params)

    respond_to do |format|
      if @unit_image.save
        format.html { redirect_to @unit_image, notice: 'Unit image was successfully created.' }
        format.json { render json: @unit_image, status: :created, location: @unit_image }
      else
        format.html { render action: "new" }
        format.json { render json: @unit_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /unit_images/1
  # PATCH/PUT /unit_images/1.json
  def update
    @unit_image = UnitImage.find(params[:id])

    respond_to do |format|
      if @unit_image.update_attributes(unit_image_params)
        format.html { redirect_to @unit_image, notice: 'Unit image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @unit_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /unit_images/1
  # DELETE /unit_images/1.json
  def destroy
    @unit_image = UnitImage.find(params[:id])
    @unit_image.destroy

    respond_to do |format|
      format.html { redirect_to unit_images_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def unit_image_params
      params.require(:unit_image).permit(:image, :unit_id)
    end
end
