module Api
  module V2
    class DocTypesController < ApplicationController 
      #before_filter :authenticate_user_with_token!,only: [:index,:create]
      
      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/doc_types', "List of all document types."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			def index
        @doc_types = DocType.order("id desc")

        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception  
      end

		end	
	end
end