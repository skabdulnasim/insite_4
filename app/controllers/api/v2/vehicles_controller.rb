module Api
  module V2
    class VehiclesController < ApplicationController
      
      def index
        if AppConfiguration.get_config_value('shipping_module') == 'enabled'
           _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
          @vehicles = Vehicle.where("unit_id = ? AND is_trashed = ?", _unit_id, FALSE)
        else
          @vehicle_disabled = "Shipping module disabled."
        end 
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception       
      end
      api :GET, '/api/v2/vehicles/get_pickup_packages', "List of packages."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."      
      param :vehicle_id, String, :required => true, :desc => "Id of the vehicle"
      param :status, String, :required => false, :desc => "status of Shipping"
      def get_pickup_packages
        @status = params[:status]
        @vehicle = Vehicle.find(params[:vehicle_id])
        @packages = @vehicle.stock_transfers.desc_order
        @packages = @packages.set_status_in(params[:status]) if params[:status].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'update_shipment_status' action
      api :PUT, '/api/v2/vehicles/update_shipment_status', "Update status of shipment."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."      
      param :transaction_id, String, :required => true, :desc => "Id of the transaction"
      param :status, String, :required => true, :desc => "status of Shipping that need to be updated"
      def update_shipment_status
        begin
          ActiveRecord::Base.transaction do
            @status = params[:status]
            @stock_transfer = StockTransfer.find(params[:transaction_id])
            @stock_transfer.update_attribute(:status, params[:status])
          end
        rescue Exception => e
        @log = Rscratch::Exception.log(@error,request) if @error.present?
        end
      end

    end
  end
end
