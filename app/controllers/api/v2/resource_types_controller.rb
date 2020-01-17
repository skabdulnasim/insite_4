module Api
  module V2
    class ResourceTypesController < ApplicationController

      before_filter :authenticate_user_with_token!

      load_and_authorize_resource

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/resource_types', "List of all resouce_types. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."

      ### => 'index' API Defination
      def index
        @resource_types = ResourceType.all
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

    end
  end
end
