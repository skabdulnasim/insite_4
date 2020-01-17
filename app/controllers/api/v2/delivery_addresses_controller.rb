module Api
	module V2
		class DeliveryAddressesController < ApplicationController

			api :GET, '/api/v2/delivery_addresses', "Api for delivery_addresses."
			param :unit_id, String, :required=>true, :desc=>"unit_id"
			param :email, String, :required=>true, :desc => "Email ID of user, who is sending request." 
			param :device_id, String, :required=>true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
			param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 10 results"
			param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 10 results. If you want to define the number of results per ependent on parameter"      
			
			def index
				_per = params[:count] || 10
				@delivery_address_unit = DeliveryAddressesUnit.find_by_address_unit(params[:unit_id]) if params[:unit_id].present?
        @count = @delivery_address_unit.count
        @delivery_address_unit = @delivery_address_unit.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present?		
			end
		end
	end
end