module Api
  module V2
    class ItemPreferencesController < ApplicationController

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/item_preferences', "List of all item preferences."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      ### => 'index' API Defination
      def index
        @item_preferences = ItemPreference.all
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

    end
  end
end
