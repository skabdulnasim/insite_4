module Api
	module V2
		class BillReprintsController < ApplicationController
			def index
				@order=BillOrder.all
				render json: {data: @order},status: :ok
			end
			
			########### API PIE for create action##
			api :POST, '/api/v2/bill_reprints', "Reprint an existing bill.(Authorization header required for authentication)"
			param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
		    param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
		    param :bill_reprint, Hash, :required => true, :desc => <<-EOS
          ==== A sample parameter value is given below
            {
              "bill_id" : "9700",
              "user_id" : "04",
              "reprint_reason" : "demo reprint",
              "recorded_at":"2018-09-05 13:18:14.184296"
            }
        EOS
		    ########################################

			def create
				@reprint=BillReprint.create(params[:bill_reprint])
				if @reprint.save
					# render json: {Status:"successfull", Message:"reprint details successfuly added  and reprint count has been updated", Data:@reprint,Reprint_count:@reprint.bill.reprint_count, Reprint_details:@bill.bill_reprints.all},status: :ok
				end
			end

			# ############ API PIE for show action ##################
			# api :POST, '/api/v2/bill_reprints/:id', "Respond with all reprint history against a bill id.(Authorization header required for authentication)"
			# param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
		 	# param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
		 	##########################################################

			def show
				@reprint_details=Bill.find(params[:id]).bill_reprints.all
				# render json:{data:@reprint_details},status: :ok
			end

			private

		end
	end
end
