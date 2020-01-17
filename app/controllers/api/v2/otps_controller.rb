module Api
  module V2
    class OtpsController < ApplicationController

    	### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/otps', "Create otp and send to the mobile number."
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :phone_number, String, :required => true, :desc => "Mobile number, where otp is to be sent."

    	def create
    		ActiveRecord::Base.transaction do
    			@customer  = Customer.find_by_mobile_no(params[:phone_number])
				  unless @customer.present?
				  	@phone_number = Otp.new()
				  	@phone_number.phone_number = params[:phone_number]
				  	@phone_number.save
				  	@phone_number.generate_pin
				  	@phone_number.send_pin
				  end	
			  end
			end

			### => API Documentation (APIPIE) for 'update' action
      api :PUT, '/api/v2/otps/:id', "Verification of the otp sent to the mobile number."
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :otp, String, :required => true, :desc => "Otp sent to the Mobile number."

			def update
			  @phone_number = Otp.find(params[:id])
			  raise "You have entered a wrong otp." unless @phone_number.otp == params[:otp]
			  @phone_number.verify(params[:otp])

			  rescue Exception => @error
      	@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			### => API Documentation (APIPIE) for 'resend' action
      api :PUT, '/api/v2/otps/resend', "Resend the otp to the mobile number if it has been failed first time."
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :phone_number, String, :required => true, :desc => "Mobile number, where otp is to be sent."

			def resend
				#@phone_number = Otp.find(params[:id])
				@phone_number = Otp.find_by_phone_number(params[:phone_number])
				raise "Customer not found with #{params[:phone_number]}." unless @phone_number.present?
				@phone_number.send_pin
				rescue Exception => @error
      	@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
  
    end
  end
end