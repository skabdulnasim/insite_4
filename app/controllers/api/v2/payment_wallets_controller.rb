module Api
  module V2
    class PaymentWalletsController < ApplicationController
    	#before_filter :authenticate_user_with_token!

    	### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/payment_wallets/', "List of all wallets."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      
      ### => 'index' API Defination
    	def index
		    @wallets = PaymentWallet.all
		    rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present?
		  end

   	end
  end
end