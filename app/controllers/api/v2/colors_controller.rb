module Api
	module V2
		class ColorsController < ApplicationController

			### => API Documentation (APIPIE) for 'index' action
			api :GET, '/api/v2/colors', "List of all colors."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"
      ### => 'index' API Defination
			def index
				@colors = Color.order('id asc')
				@total_count = @colors.count
				_per = params[:per] || 20
				@colors = @colors.page(params[:page]).per(_per) if params[:page].present?
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
		end
	end
end