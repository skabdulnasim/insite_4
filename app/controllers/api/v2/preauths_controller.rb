module Api
	module V2
		class PreauthsController < ApplicationController
			before_filter :authenticate_user_with_token!
			load_and_authorize_resource

			### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/preauths', "API for preauth. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :preauth, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
					{
						"customer_id": "40",
						"unit_id": "40",
						"customer_queue_id": "40",
						"advance_id": "123",
						"advance_type" "CustomerQueue",
						"device_id": "YOTTO05",
						"amount": "600",
						"pre_payments_attributes":[
				       {
				          "pre_paymentmode_type":"PrePaypalPayment",
				          "pre_paymentmode_attributes":{
				             "amount":"600",
				             "transaction_id":"40",
				             "recorded_at":"2016-04-02 11:50"
				          }
				       }                                                                           
				    ]
					}
            
        EOS
      formats ['json'] 

			def create
				ActiveRecord::Base.transaction do
					@preauth = Preauth.new(params[:preauth])
					if @preauth.save
						@preauth.reload
					else
            @validation_errors = error_messages_for(@preauth)
          end
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception        
			end

			api :GET, '/api/v2/preauths/check_availability', "Check vailability for preauths."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
			param :customer_queue_id, String, :required => true, :desc => "Id of the customer queue"
			def check_availability
				@customer_queue = CustomerQueue.find(params[:customer_queue_id])
				@max_booking = @customer_queue.slot.max_booking
				@total_booking = CustomerQueue.by_date(@customer_queue.from_date.to_date).is_preauth.by_slot(@customer_queue.slot_id).sum(:pax)
				@available_pax = @max_booking - @total_booking
				_preauth = @customer_queue.unit.unit_detail.options[:preauth]
        pax = @customer_queue.pax
        unless @customer_queue.pax.even?
          pax = @customer_queue.pax + 1
        end 
        @preauth = _preauth.to_f * pax
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception 
			end

		end
	end
end