class NewsEventsController < ApplicationController
  load_and_authorize_resource

  layout "material"
  before_filter :set_module_details
  # GET /news_events
  # GET /news_events.json
  def index
    @news_events = NewsEvent.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news_events }
    end
  end

  # GET /news_events/1
  # GET /news_events/1.json
  def show
    @news_event = NewsEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @news_event }
    end
  end

  # GET /news_events/new
  # GET /news_events/new.json
  def new
    @news_event = NewsEvent.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @news_event }
    end
  end

  # GET /news_events/1/edit
  def edit
    @news_event = NewsEvent.find(params[:id])
  end

  def create
    ActiveRecord::Base.transaction do
      @news_event = NewsEvent.new(params[:news_event])
      respond_to do |format|
        if @news_event.save and UnitNewsEvent.save_unit_news(@news_event.id, params['unit_ids']) 
          if params[:news_event_gallery][:news_event_image].present?
            NewsEventGallery.save_multiple_images(@news_event.id, params[:news_event_gallery][:news_event_image]) 
          end
          format.html { redirect_to @news_event, notice: 'Advertisement was successfully created.' }
          format.json { render json: @news_event, status: :created, location: @news_event }
        else
          format.html { render action: "new" }
          format.json { render json: @news_event.errors, status: :unprocessable_entity }
        end
      end
    end
    rescue Exception => e
      respond_to do |format|
        format.html { render action: "new", notice: 'Fill the form properly.' }
      end
  end

  # PATCH/PUT /news_events/1
  # PATCH/PUT /news_events/1.json

  def update
    @news_event = NewsEvent.find(params[:id])

    respond_to do |format|
      if @news_event.update_attributes(params[:news_event]) and UnitNewsEvent.save_unit_news(@news_event.id, params['unit_ids'])
        if params[:news_event_gallery][:news_event_image].present?
          NewsEventGallery.save_multiple_images(@news_event.id, params[:news_event_gallery][:news_event_image]) 
        end
        format.html { redirect_to @news_event, notice: 'News event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @news_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news_events/1
  # DELETE /news_events/1.json
  def destroy
    @news_event = NewsEvent.find(params[:id])
    @news_event.destroy

    respond_to do |format|
      format.html { redirect_to news_events_url }
      format.json { head :no_content }
    end
  end

  private

    def set_module_details
      @module_id = "news_event"
      @module_title = "News Event"
    end  
end
