class AdvertisementGalleriesController < ApplicationController
  
  # GET /advertisement_galleries
  # GET /advertisement_galleries.json
  def index
    @advertisement_galleries = AdvertisementGallery.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @advertisement_galleries }
    end
  end

  # GET /advertisement_galleries/1
  # GET /advertisement_galleries/1.json
  def show
    @advertisement_gallery = AdvertisementGallery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @advertisement_gallery }
    end
  end

  # GET /advertisement_galleries/new
  # GET /advertisement_galleries/new.json
  def new
    @advertisement_gallery = AdvertisementGallery.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @advertisement_gallery }
    end
  end

  # GET /advertisement_galleries/1/edit
  def edit
    @advertisement_gallery = AdvertisementGallery.find(params[:id])
  end

  # POST /advertisement_galleries
  # POST /advertisement_galleries.json
  def create
    @advertisement_gallery = AdvertisementGallery.new(params[:advertisement_gallery])

    respond_to do |format|
      if @advertisement_gallery.save
        format.html { redirect_to @advertisement_gallery, notice: 'Advertisement gallery was successfully created.' }
        format.json { render json: @advertisement_gallery, status: :created, location: @advertisement_gallery }
      else
        format.html { render action: "new" }
        format.json { render json: @advertisement_gallery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /advertisement_galleries/1
  # PUT /advertisement_galleries/1.json
  def update
    @advertisement_gallery = AdvertisementGallery.find(params[:id])

    respond_to do |format|
      if @advertisement_gallery.update_attributes(params[:advertisement_gallery])
        format.html { redirect_to @advertisement_gallery, notice: 'Advertisement gallery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @advertisement_gallery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /advertisement_galleries/1
  # DELETE /advertisement_galleries/1.json
  def destroy
    @advertisement_gallery = AdvertisementGallery.find(params[:id])
    @advertisement_gallery.destroy

    respond_to do |format|
      format.html { redirect_to advertisement_galleries_url }
      format.json { head :no_content }
    end
  end
end
