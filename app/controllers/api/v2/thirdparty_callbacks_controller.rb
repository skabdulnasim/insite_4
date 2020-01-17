module Api
  module V2
    class ThirdpartyCallbacksController < ApplicationController

    	# load_and_authorize_resource

      require 'rest-client'
      require 'json'

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/thirdparty_callbacks', "API to place new thirdparty callback."
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the external order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :callback_type, String, :required => true, :desc => "External order source i.e. zomato, urban_piper, foodpanda etc."
      ### => 'create' API

      def create
        ActiveRecord::Base.transaction do
          @thirdparty_callback = ThirdpartyCallback.new
          @thirdparty_callback.callback_type = params[:callback_type]
          @thirdparty_callback.data = params.to_json
          @thirdparty_callback.save
          if @thirdparty_callback.save
            render json: {:status=>'success', :message => "Callback placed successfully.",:code => 200 , :data=> params.to_json}
          else
            render json: {:status=>"failed", :message => "Something went wrong while placing callback.",:code => 500, :data=> {}}
          end
        end
      end

      ### => API Documentation (APIPIE) for 'show' action
      api :GET, '/api/v2/thirdparty_callbacks/:id', "API to fetch a thirdparty callback."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      formats ['json']

      ### => 'show' API Defination      
      def show
        @thirdparty_callback = ThirdpartyCallback.find(params[:id])
        
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
    end
  end
end