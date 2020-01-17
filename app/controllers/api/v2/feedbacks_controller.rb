module Api
  module V2
    class FeedbacksController < ApplicationController
      load_and_authorize_resource

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/feedbacks', "List of all feedbacks."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "Advertisements of this unit"
      ### => 'index' API Defination
      def index
        @unit = Unit.find(params[:unit_id])
        @feedbacks = @unit.unit_feedbacks
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

    end
  end
end
