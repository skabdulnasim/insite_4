module Api
	module V2
		class DenominationsController < ApplicationController
			api :GET, '/api/v2/denominations', "Api for listing of cash handlings."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
			param :country_name, String, :required => false, :desc => "Country of current user"
			def index
				 @countries = Country.order("id")
				 @countries = @countries.by_country(params[:country_name]) if params[:country_name].present?
				rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
		end
	end
end