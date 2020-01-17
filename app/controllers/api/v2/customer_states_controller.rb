module Api
	module V2
		class CustomerStatesController < ApplicationController

			api :GET, '/api/v2/customer_states', "List of all customer states."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."

			def index
				@customer_states = CustomerState.where("status=?","active")
			end
		end
	end
end