class AdvertisementsController < ApplicationController

  load_and_authorize_resource

  layout "material"
  before_filter :set_module_details
  
  # GET /advertisements
  # GET /advertisements.json
  def index
    @advertisements = Advertisement.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @advertisements }
    end
  end

  # GET /advertisements/1
  # GET /advertisements/1.json
  def show
    @advertisement = Advertisement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @advertisement }
    end
  end

  # GET /advertisements/new
  # GET /advertisements/new.json
  def new
    @sections = Section.where("unit_id=?",@current_user.unit_id)
    @advertisement = Advertisement.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @advertisement }
    end
  end

  # GET /advertisements/1/edit
  def edit
    @sections = Section.where("unit_id=?",@current_user.unit_id)
    @advertisement = Advertisement.find(params[:id])
  end

  # POST /advertisements
  # POST /advertisements.json
  def create
    ActiveRecord::Base.transaction do
      @advertisement = Advertisement.new(params[:advertisement])
      respond_to do |format|
        if @advertisement.save and UnitAdvertisement.save_unit_advertisement(@advertisement.id, params['unit_ids']) 
          if params[:advertisement_gallery].present?
            AdvertisementGallery.save_multiple_images(@advertisement.id, params[:advertisement_gallery][:advertisement_image]) 
          end
          format.html { redirect_to @advertisement, notice: 'Advertisement was successfully created.' }
          format.json { render json: @advertisement, status: :created, location: @advertisement }
        else
          format.html { render action: "new" }
          format.json { render json: @advertisement.errors, status: :unprocessable_entity }
        end
      end
    end
    rescue Exception => e
      respond_to do |format|
        format.html { render action: "new", notice: 'Fill the form properly.' }
      end
  end

  # PUT /advertisements/1
  # PUT /advertisements/1.json
  def update
    @advertisement = Advertisement.find(params[:id])

    respond_to do |format|
      if @advertisement.update_attributes(params[:advertisement]) and UnitAdvertisement.save_unit_advertisement(@advertisement.id, params['unit_ids'])
        if params[:advertisement_gallery].present?
          AdvertisementGallery.save_multiple_images(@advertisement.id, params[:advertisement_gallery][:advertisement_image]) 
        end
        format.html { redirect_to @advertisement, notice: 'Advertisement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @advertisement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /advertisements/1
  # DELETE /advertisements/1.json
  def destroy
    @advertisement = Advertisement.find(params[:id])
    @advertisement.destroy

    respond_to do |format|
      format.html { redirect_to advertisements_url }
      format.json { head :no_content }
    end
  end

  def remove_pic 
    puts "remove hit "
    puts params[:gallery_id]
    advertisement_gallery_id = params[:gallery_id]
    delete_status = AdvertisementGallery.delete_single_images(advertisement_gallery_id)
    respond_to do |format|
      format.json { render json: delete_status}
    end
  end
  private

  def set_module_details
    @module_id = "advertisements"
    @module_title = "Advertisements"
  end  
end
