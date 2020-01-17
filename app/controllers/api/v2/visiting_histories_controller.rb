module Api
	module V2
		class VisitingHistoriesController < ApplicationController

			### => API Documentation (APIPIE) for 'index' action
			api :GET, '/api/v2/visiting_histories', "List of all visiting histories."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "Unit id of current user"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"
      ### => 'index' API Defination
			def index
				@visiting_histories = VisitingHistory.by_unit(params[:unit_id])
				@total_count = @visiting_histories.count
				_per = params[:per] || 20
				@visiting_histories = @visiting_histories.page(params[:page]).per(_per) if params[:page].present?
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			### => API Documentation (APIPIE) for 'index' action
      api :POST, '/api/v2/visiting_histories', "API to generate a visiting histories."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :visiting_history, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
        {
          "day": "Sunday",
          "in_time": "10:33:00",
          "out_time": "10:50:00",
          "latitude": "24.1234",
          "longitude": "28.1243",
          "resource_id": "2",
          "visiting_type" : "Default",
          "visting_reason" : "Allocate by manager",
          "unit_id" : "3",
          "user_id": "1",
          "device_id" : "123",
          "recorded_at":"2016-04-02 11:50",
          "customer_id" :12,
          "customer_state_id":2,
          "address_id":1,
          "visited_entity_id":2,
          "visited_entity_type:"Vendor"
        } 
      EOS
      formats ['json']
			def create
				ActiveRecord::Base.transaction do
					@visiting_history = VisitingHistory.new(params[:visiting_history])
					unless @visiting_history.save
          	@validation_errors = error_messages_for(@visiting_history)
        	end
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
		end
	end
end