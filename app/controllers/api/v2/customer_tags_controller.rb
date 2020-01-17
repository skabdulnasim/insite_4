module Api
	module V2
		class CustomerTagsController < ApplicationController
			api :GET, '/api/v2/customer_tags', "List of customer_tags for a specific customer"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			param :customer_id, String, :required=>true, :desc=>"customer id(can be provided through URL)"
			def index
				if Customer.find(params[:customer_id]).present?
					@customer_tags = CustomerTag.by_customer_id(params[:customer_id])
				else
					raise "Could not find customer with id #{params[:customer_id]}"
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end


			api :POST, '/api/v2/customer_tags', "add tag for customer"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :customer_id,Integer,:required=>true, :desc=> "Id of customer"
      param :tag_id,Integer,:required=>true, :desc=>"ID of tag"
			def create
				if Customer.find(params[:customer_id]).present? and Tag.find(params[:tag_id]).present?
					if !CustomerTag.is_present(params[:customer_id],params[:tag_id]).present?
						puts "customer tag can be created"
						@customer_tag = CustomerTag.create(:customer_id=>params[:customer_id],:tag_id=>params[:tag_id])
					else
						raise "Record already present"
					end
				else
					raise "Could not find customer or tag"
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
		end
	end
end