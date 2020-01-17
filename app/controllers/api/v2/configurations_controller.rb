module Api
  module V2
    class ConfigurationsController < ApplicationController
      before_filter :authenticate_user_with_token!
      # load_and_authorize_resource

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/configurations', "List of system configurations. (Authorization header required for authentication)"
      param :email, String, :required => false, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."      
      param :tsp, String, :required => false, :desc => "Travelling sales man is configuration"
      param :config_keys, Array, :required => false, :desc => "Config value of the config keys"
      ### => 'index' API Defination      
      def index
        if params[:tsp].present? && params[:tsp] == 'yes'
          @configurations = AppConfiguration.tsp_configuration
        else  
          @configurations = AppConfiguration.order("id asc")
          @configurations = @configurations.set_keys(params[:config_keys]) if params[:config_keys].present?
        end  
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception        
      end
    end
  end
end