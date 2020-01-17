module Api
  module V2
    class PartiesController < ApplicationController
      api :POST, '/api/v2/parties', "API to place new party."
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :party, Hash, :required => true, :desc => <<-EOS
      ==== A sample parameter value is given below
        {
          "name": "birthday party",
          "party_type": "dutch",
          "owner_id": "2",
          "date_time": "2017-12-05 11:50"
        }
      EOS
      formats ['json']
      def create
        ActiveRecord::Base.transaction do
          @party = Party.new(params[:party])
          unless @party.new_record? and @party.save
            @validation_errors = error_messages_for(@party)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :GET, '/api/v2/parties/:id', "API to get a party details."
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      def show
        @party = Party.find(params[:id])
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :PUT, '/api/v2/parties/:id', "API to get a party details."
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :party, Hash, :required => true, :desc => <<-EOS
      ==== A sample parameter value is given below
        {
          "name": "Anniversary party",
          "party_type": "nondutch",
          "date_time": "2017-12-05 11:50"
        }
      EOS
      formats ['json']
      def update
        ActiveRecord::Base.transaction do
          @party = Party.find(params[:id])
          if @party.update_attributes(params[:party])
            @party.reload
          else
            @validation_errors = error_messages_for(@party)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end
