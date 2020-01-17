module Api
	module V2
		class LabelsController < ApplicationController
			### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/labels', "List of all label."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"      
      param :customer_state, String, :required => false
      def index
      	@customers_labels = Label.all
      	@customers_labels = Label.by_customer_state(params[:customer_state]) if params[:customer_state].present?
      	@count = @customers_labels.count
      	@customers_labels = @customers_labels.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error
        @log  = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
		end
	end
end