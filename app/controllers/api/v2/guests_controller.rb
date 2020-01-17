module Api
  module V2
    class GuestsController < ApplicationController
      api :POST, '/api/v2/guests', "API to place new party."
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :guest, Hash, :required => true, :desc => <<-EOS
      ==== A sample parameter value is given below
        {
          "email":"abc.gmail.com",
          "mobile_no":"9674442296"
          "party_id": "2",
          "party_code": "qwe234"
        }
      EOS
      formats ['json']
      def create
        ActiveRecord::Base.transaction do
          @guest = Guest.new(params[:guest])
          unless @guest.new_record? and @guest.save
            @validation_errors = error_messages_for(@guest)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
    end
  end
end
