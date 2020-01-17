require 'json'
require 'em-http'
module Api
	module V2
		class KnowlaritiesController <ApplicationController
			def index
			end
			def knowlarity_call_log
				if params[:agent_number].present? and params[:customer_number].present?
					agent_number = params[:agent_number]
					customer_number = params[:customer_number]
					agent = Knowlarity.where("agent_phone_number=?",agent_number).first
					if agent.present?
						agent.update_attribute(:customer_phone_number,customer_number)
					else
						new_knowlarity_log = Knowlarity.create(:agent_phone_number=>agent_number,:customer_phone_number=>customer_number)
					end
					respond_to do |format|
						format.json{render(json:{:status=>"ok"})}
					end
				else
					respond_to do |format|
						format.json{render(json:{:status=>"error",:internal_message=>"Agent's number and Customer's number must be present"})}
					end
				end
			end
			api :GET, 'api/v2/knowlarities/fetch_current_knowlarity_customer', "to fetch knwolarity customer informations"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :agent_phone_number, String, :required => true, :desc => "mobile number of the agent who is receiving the call,please elemenet the leading '+91' from the phone number"
			def fetch_current_knowlarity_customer
				knowlarity = Knowlarity.where("agent_phone_number=?",params[:agent_phone_number]).first
				if  knowlarity.present?
					@customer_number = knowlarity.customer_phone_number.strip
					@customer = Customer.by_mobile(@customer_number).first
        	@customer_profile = @customer.profile if @customer.present?
				end
        raise "No record found" if @customer[:error].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
		end 
	end
end