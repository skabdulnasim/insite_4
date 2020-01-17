module Api
	module V2
		class CustomerNotesController < ApplicationController
			### => API Documentation (APIPIE) for 'index' action
			api :GET, '/api/v2/customer_notes', "List of notes for a customer"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :customer_id,String,:required=>true, :desc=>"ID of the customer"
			def index
				@customer_notes = CustomerNote.where("customer_id=?",params[:customer_id])
				raise "Couldn't find customer_id" if !@customer_notes.present?
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			### => API Documentation (APIPIE) for 'create' action
			api :POST, '/api/v2/customer_notes', "create customer notes"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :customer_note,Hash,:required=>true, :desc=> <<-EOS

          ==== A sample parameter value is given below
            {
              "customer_id":4,
              "notes":"need to call the customer"
            }
        EOS
      	formats ['json']			
			def create
				@customer = CustomerStateTransition.where("customer_id=?",params[:customer_note][:customer_id]).first
				if @customer.present?
					@customer_note=CustomerNote.create(params[:customer_note])
				else
					raise "Couldn't find customer_id"
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
		end
	end
end