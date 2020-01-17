class ProductionDashboardController < ApplicationController
	layout "material"

	include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details
	before_filter :set_timerange

	def index	
	end
	def get_production_date
		@today_productions = StockProduction.where("Date(created_at)=?", DateTime.now.to_date)
		@all_productions = StockProduction.all
		@productions = []
		@all_productions.each do |production|
			production.stock_production_metas.each do |meta|
				@production_meta = {"id"=>production.id,"name"=>meta.product.name , "start_date"=> production.start_date , "end_date"=>production.end_date, "status"=> production.status,"unit_id"=>production.store_id}
				@productions.push(@production_meta)
			end
		end
		respond_to do |format|
      format.js # index.js.erb
      format.html # index.html.erb
      format.json { render json: {all_data: {today_production:@today_productions,all_production:@productions}}}
    end
		# @all_production.each do |production|
		# 	puts production
		# end
	end

	def get_production_details_by_status
		@production_details = StockProduction.where("status=? AND Date(created_at)=?",params[:status],DateTime.now.to_date)
		@production_details.each do |production_details|
			puts production_details.status
		end
		respond_to do |format|
      format.json { render json:@production_details}
    end
	end

	private
  def set_module_details
    @module_id = "dashboard"
    @module_title = "Production Dashboard"
  end
end
