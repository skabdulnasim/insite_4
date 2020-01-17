module Api
  module V2
    class ResourceProductStocksController < ApplicationController

      ### => API Documentation (APIPIE) for 'index' action
      api :POST, '/api/v2/resource_product_stocks', "API to generate a Product stock."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :resource_product_stock, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
        {
          "product_id": "2",
          "resource_id": "1",
          "stock": "7",
          "recorded_at":"2016-04-02 11:50",
          "user_id": "1"
        } 
      EOS
      formats ['json']
      def create
        @resource_product_stock = ResourceProductStock.new(params[:resource_product_stock])
        unless @resource_product_stock.save
          @validation_errors = error_messages_for(@resource_product_stock)
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

    end
  end
end
