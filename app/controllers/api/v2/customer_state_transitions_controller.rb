module Api
	module V2
		class CustomerStateTransitionsController < ApplicationController
			api :GET, '/api/v2/customer_state_transitions', "List of states of a customer"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			param :customer_id, String, :registered=>true, :desc=>"customer id"
			def index
				@customer_transition= CustomerStateTransition.by_customer_id(params[:customer_id])
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			api :POST, '/api/v2/customer_state_transitions', "create customer in different state"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :customer_state_transition,Hash,:required=>true, :desc=> <<-EOS

          ==== A sample parameter value is given below
            {
              "user_id":4,
              "customer_state_transition_id":2,
              "customer_communications_attributes":[
                {
                "communication_medium":"email",
                "communication_details":"formal introductions about the customer"
                }
              ]
            }
        EOS
      	formats ['json']
			def create
				if Customer.find(params[:customer_state_transition][:customer_id]).present? and CustomerState.find(params[:customer_state_transition][:customer_state_id]).present?
					if !CustomerStateTransition.find_is_present(params[:customer_state_transition][:customer_id],params[:customer_state_transition][:customer_state_id]).present?
						@customer_state_transition = CustomerStateTransition.create(params[:customer_state_transition])
					else
						@validation_error = 1
					end
				else
						@error=1
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
		end
	end
end