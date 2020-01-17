module Api
  module V2
    class ProformasController < ApplicationController

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/proformas', "API to generate a proforma."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :proforma, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "customer_id": "1",
              "device_id": "Yotto05",
              "serial_no": "3-3495-3",
              "discount": "20",
              "recorded_at": "2019-01-10",
              "remarks": "1st pro",
              "roundoff": "10",
              "status": "",
              "unit_id": "7",
              "user_id": "16",
              "vehicle_id": "1",
              "order_proformas_attributes":[
                {
                "order_id":"10004"
                },
                {
                "order_id":"10005"
                }
              ]
            }
        EOS
      formats ['json']

      def create
        ActiveRecord::Base.transaction do
          raise "Serial no must be present." unless params[:proforma][:serial_no].present?
          @proforma = Proforma.find_by_serial_no(params[:proforma][:serial_no]) if params[:proforma][:serial_no].present?
          @proforma = Proforma.new(params[:proforma]) unless @proforma.present?
          if @proforma.save
            @proforma.reload
          else  
            @validation_errors = error_messages_for(@proforma)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def show
        @proforma = Proforma.find(params[:id])
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error, request) if @error.present?
      end
      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/proformas', "List of all proformas."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "Filter proformas of an unit"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :customer_id, String, :required => false, :desc => "Get proforma of the customer"
      param :bill_status, String, :required => false, :desc => "Filter only billed (value: 1) or unbilled proformas (value: 0)."
      def index
        _per = params[:count] || 20
        @proformas = Proforma.order('id desc').by_unit(params[:unit_id])
        @proformas = @proformas.by_customer(params[:customer_id]) if params[:customer_id].present?
        @proformas = @proformas.by_billed_status(params[:bill_status]) if params[:bill_status].present?
        @count = @proformas.count
        @proformas = @proformas.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end