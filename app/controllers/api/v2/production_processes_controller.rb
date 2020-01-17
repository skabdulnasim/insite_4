module Api
	module V2
		class ProductionProcessesController < ApplicationController
			before_filter :authenticate_user_with_token!
			load_and_authorize_resource

			### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/production_processes', "List of all processes."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :category_id, String, :required => false, :desc => "Filter product by category_id"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"
      ### => 'index' API Defination
			def index
				_per = params[:per] || 100
				@production_processes = ProductionProcess.order("id asc")
				@production_processes = @production_processes.by_category_id(params[:category_id]) if params[:category_id].present?
				@processes_count = @production_processes.count
				@production_processes = @production_processes.page(params[:page]).per(_per) if params[:page].present?
				
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

		end
	end
end