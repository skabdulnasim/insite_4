module Api
	module V2
		class ReasonCodesController < ApplicationController
			
			###APIPIE documentation for reason code index API
			api :GET, '/api/v2/reason_codes', "List of all reason code details for a specific model and specific model action."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			param :model_action_id,String, :required=>true, :desc=> "Model action ID of a particular model"
			def index
				@model_action  = ModelAction.find(params[:model_action_id])
				if @model_action.present?	
					@reasons = @model_action.reason_codes
				else
					raise "no model action found with the id=#{params[:model_action_id]}"
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			####APIPIE documentation for master_models
			api :GET, '/api/v2/reason_codes/master_models', "Get the list of all master models"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			def master_models
				@master_model = MasterModel.order("name ASC")
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
			

			###APIPIE documentation for model_action API
			api :GET, '/api/v2/reason_codes/model_actions', "Get the detailed list of all model_action for a particular model"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			param :model_name,String, :required=>true, :desc=> "model name"
			def model_actions
				@master_model  = MasterModel.where("name=?",params[:model_name].capitalize.singularize.camelize).first
				if  @master_model.present?
					@model_actions = @master_model.model_actions
				else
					raise "unable to find model name #{params[:model_name]}"
				end
				
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
		end
	end
end