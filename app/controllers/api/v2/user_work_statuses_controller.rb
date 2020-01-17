module Api
  module V2
    class UserWorkStatusesController < ApplicationController

      ### => API Documentation (APIPIE) for 'index' action
      api :POST, '/api/v2/user_work_statuses', "API to generate a User Work Statuses."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :user_work_statuses, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
        {
          "user_id": "12",
          "latitude": "88.74562",
          "longitude": "88.73456",
          "recorded_at":"2016-04-02 11:50",
          "work_status":"Leave",
          "remarks": "1",
          "device_id":"YOTTO05"
        } 
      EOS
      formats ['json']
      def create
        @user_work_status = UserWorkStatus.new(params[:user_work_statuses])
        unless @user_work_status.save
          @validation_errors = error_messages_for(@resource_product_stock)
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :GET, '/api/v2/user_work_statuses/work_statuses', "List of all bills. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      def work_statuses
        @work_statuses = UserWorkStatus::WORKSTATUS
        rescue Exception => @error
        @log  = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

    end
  end
end
