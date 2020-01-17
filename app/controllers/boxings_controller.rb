class BoxingsController < ApplicationController
	
	include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
	
	def index
		@boxings  = Boxing.order('created_at desc')
		smart_listing_create :boxings, @boxings, partial: "boxings/boxings_smartlist"
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
	end

	def new
		@packages = Package.where("production_status != ?", '0')
	end

	def show
		@boxing = Boxing.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
	end

	def edit
				
	end

end