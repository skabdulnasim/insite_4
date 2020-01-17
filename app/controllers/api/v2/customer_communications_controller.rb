module Api
	module V2
		class CustomerCommunicationsController < ApplicationController
			### => API Documentation (APIPIE) for 'create' action
			api :POST, '/api/v2/customer_communications', "Create customer communication for particular customer with customer_state."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :customer_communication,Hash,:required=>true, :desc=> <<-EOS

          ==== A sample parameter value is given below
            {
              "user_id":"4",
              "customer_state_transition_id":2,
              "communication_medium":"mail",
              "communication_details":"about business"
            }
        EOS
      	formats ['json']
			def create
				if CustomerStateTransition.find(params[:customer_communication][:customer_state_transition_id]).present? and User.find(params[:customer_communication][:user_id]).present?
					@customer_communication = CustomerCommunication.create(params[:customer_communication])
				else
					@error = 1
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end


			### => API Documentation (APIPIE) for 'communications' action
			api :GET, '/api/v2/customer_communications/communications', "List of communications  of a particular customer with customer_state."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			param :customer_id, Integer, :required=>true,:desc=>"ID of the customer"
			param :customer_state_id, Integer, :required=>false, :desc=>"State Id of the customer"
			def communications
				_per  = params[:count] || 20
				_page  = params[:page] || 0 
				@communication_details = {}
				if params[:customer_state_id].present?
					_customer_state_transition = CustomerStateTransition.where("customer_id=? and customer_state_id=?",params[:customer_id],params[:customer_state_id]).first
					@communication_details["#{_customer_state_transition.customer_state.name}"]=get_communication(params[:customer_id],_customer_state_transition.id,_per,_page)
				else
					_customer_uniq_transition_id =CustomerStateTransition.where("customer_id=?",params[:customer_id]).select("id,customer_state_id")
					_customer_uniq_transition_id.each do |transition|
						@communication_details["#{transition.customer_state.name}"]=get_communication(params[:customer_id],transition.id,_per,_page)
					end
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			private 
			def get_communication(customer_id,customer_state_transition_id,per,page)
				_communication_array=[]
				_communications = CustomerCommunication.where("customer_id=? and customer_state_transition_id=?",customer_id,customer_state_transition_id)
				_communications = _communications.page(page).per(per) if page>0
				_communications.each do |communication|
					_communication_array.push({:user_id=>communication.user_id,:customer_id=>communication.customer_id, :customer_state_transition_id=>communication.customer_state_transition_id,:customer_state=>communication.customer_state_transition.customer_state.name, :communication_medium=>communication.communication_medium,:communication_details=>communication.communication_details,:recorded_at=>communication.recorded_at})
				end
				return _communication_array
			end
		end
	end
end