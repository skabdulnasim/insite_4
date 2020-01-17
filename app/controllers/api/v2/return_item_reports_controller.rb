module Api
	module V2
		class ReturnItemReportsController <  ApplicationController

			before_filter :set_timerange, only: [:index]

			#=> API Documentation (APIPIE) for 'index' action 
			api :GET, '/api/v2/return_item_reports', "API for return report."
			param :unit_id, String, :required=>false, :desc=>"unit_id"
			param :email, String, :required=>true, :desc => "Email ID of user, who is sending request." 
			param :device_id, String, :required=>true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
			param :page, String, :required=>false, :desc => "If `page` parameter is present in requests, this API will response with pagination and by default it will return 10 results"
			param :count, String, :required=>false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 10 results. If you want to define the number of results per ependent on parameter"
			param :from_date, String, :required=>true, :desc => "from_date of return bill"
			param :to_date, String, :required=>true, :desc => "to_date of return bill"

			def index
				_per = params[:count] || 10
				@return_report = ReturnItem.order('id desc')

				@return_report = @return_report.unit_return(params[:unit_id]) if params[:unit_id].present?
				@return_report = @return_report.by_date_range(@from_datetime,@to_datetime) if params[:from_date].present? and params[:to_date].present?

				@count = @return_report.count
				@return_report = @return_report.page(params[:page]).per(_per) if params[:page].present?

				rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present?   
			end
		end
	end
end