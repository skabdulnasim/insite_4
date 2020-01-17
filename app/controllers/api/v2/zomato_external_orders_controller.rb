module Api
  module V2
    class ZomatoExternalOrdersController < ApplicationController
      
      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/zomato_external_orders', "API to place new External order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :order, Hash, :required => false, :desc => "The JSON Format of external order."
      ### => 'create' API

      def create
        ActiveRecord::Base.transaction do
          @ext_order = ExternalOrder.new
          @ext_order.order_source = "zomato"
          @ext_order.order = params[:order].to_json
          if @ext_order.save
           	render json: {:status=>"success", :code =>200, :message => {:simple_message=>"External Order placed successfully.", :internal_message=>"External Order placed successfully."}, :customer=> params[:customer].to_json, :order=> params[:order].to_json}
          else
          	render json: {:status=>"failed", :code =>500, :messages => {:simple_message=>"Something went wrong while placing new external order", :internal_message=>"Something went wrong while placing new external order." }, :customer=> {}, :order=> {}}
          end
        end
      end

    end
	end
end