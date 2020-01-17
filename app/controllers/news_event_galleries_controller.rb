class NewsEventGalleriesController < ApplicationController
  # GET /news_event_galleries
  # GET /news_event_galleries.json
  def index
    @news_event_galleries = NewsEventGallery.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news_event_galleries }
    end
  end

  # GET /news_event_galleries/1
  # GET /news_event_galleries/1.json
  def show
    @news_event_gallery = NewsEventGallery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @news_event_gallery }
    end
  end

  # GET /news_event_galleries/new
  # GET /news_event_galleries/new.json
  def new
    @news_event_gallery = NewsEventGallery.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @news_event_gallery }
    end
  end

  # GET /news_event_galleries/1/edit
  def edit
    @news_event_gallery = NewsEventGallery.find(params[:id])
  end

  # POST /news_event_galleries
  # POST /news_event_galleries.json
  def create
    @news_event_gallery = NewsEventGallery.new(news_event_gallery_params)

    respond_to do |format|
      if @news_event_gallery.save
        format.html { redirect_to @news_event_gallery, notice: 'News event gallery was successfully created.' }
        format.json { render json: @news_event_gallery, status: :created, location: @news_event_gallery }
      else
        format.html { render action: "new" }
        format.json { render json: @news_event_gallery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /news_event_galleries/1
  # PATCH/PUT /news_event_galleries/1.json
  def update
    @news_event_gallery = NewsEventGallery.find(params[:id])

    respond_to do |format|
      if @news_event_gallery.update_attributes(news_event_gallery_params)
        format.html { redirect_to @news_event_gallery, notice: 'News event gallery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @news_event_gallery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news_event_galleries/1
  # DELETE /news_event_galleries/1.json
  def destroy
    @news_event_gallery = NewsEventGallery.find(params[:id])
    @news_event_gallery.destroy

    respond_to do |format|
      format.html { redirect_to news_event_galleries_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def news_event_gallery_params
      params.require(:news_event_gallery).permit(:news_event_id, :news_event_image)
    end
end
