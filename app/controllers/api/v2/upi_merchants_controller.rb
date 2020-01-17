module Api
	module V2
		class UpiMerchantsController < ApplicationController

			#before_filter :authenticate_user_with_token!
			api :GET, '/api/v2/upi_merchants', "To get upi merchant settings."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			def index
				@upi_merchant=UpiMerchant.first

				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
		end
	end
end