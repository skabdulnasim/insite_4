module Api
  module V2
    class CashHandlingsController < ApplicationController
      
      before_filter :authenticate_user_with_token!
      before_filter :set_timerange, only: [:index]

      api :GET, '/api/v2/cash_handlings', "Api for listing of cash handlings. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :unit_id, String, :required => true, :desc => "Unit id of current unit"
      param :transaction_type, String, :required => false, :desc => "Transaction type is CashIn or CashOut "
      param :from_datetime, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`from_date` parameter is dependent on `to_date` parameter"
      param :to_datetime, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`to_date` parameter is dependent on `from_date` parameter"
      param :from_price, String, :required => false, :desc => "This parameter can be used to get results between two price range.", :meta => "`from_price` parameter is dependent on `to_price` parameter"
      param :to_price, String, :required => false, :desc => "This parameter can be used to get results between two price range.", :meta => "`to_price` parameter is dependent on `from_price` parameter"
      param :user_id, String, :required => false, :desc => "This parameter can be used to track different user"
      param :cash_device_id, String, :required => false, :desc => "This parameter can be used to track different device"

      def index
        _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
        _from_datetime = DateTime.parse(params[:from_datetime]).strftime("%Y-%m-%d %H:%M:%S") if params[:from_datetime].present? 
        _from_datetime = Time.zone.parse(_from_datetime).utc if params[:from_datetime].present?
        _to_datetime = DateTime.parse(params[:to_datetime]).strftime("%Y-%m-%d %H:%M:%S") if params[:to_datetime].present?
        _to_datetime = Time.zone.parse(_to_datetime).utc if params[:to_datetime].present?
        @cash_handlings = Pay.order("id desc")
        @cash_handlings = @cash_handlings.by_unit(_unit_id)
        @cash_handlings = @cash_handlings.by_user(params[:user_id]) if params[:user_id].present?
        @cash_handlings = @cash_handlings.by_device_id(params[:cash_device_id]) if params[:cash_device_id].present?
        @cash_handlings = @cash_handlings.set_transaction_type_in(params[:transaction_type]) if params[:transaction_type].present?
        @cash_handlings = @cash_handlings.by_date_range(@from_datetime,@to_datetime) if params[:from_datetime].present? and params[:to_datetime].present?
        @cash_handlings = @cash_handlings.check_price_range(params[:from_price],params[:to_price]) if params[:from_price].present? && params[:to_price].present?
        @current_cash = PayUpdate.current_cash(_unit_id)
        rescue Exception => e
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end 

      api :GET, '/api/v2/cash_handlings/:id', "Api for fetching a cash handlings. (Authorization header required for authentication)"
      param :email, String, :required => false, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      def show
        @cash_handling = Pay.find(params[:id])
        @current_cash = PayUpdate.current_cash(@cash_handling.unit_id)      
        rescue Exception => e
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
      
      api :POST, '/api/v2/cash_handlings/cash_in', "API to generate a cash in. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :cash_in, Hash, :required => true, :desc => <<-EOS
          ==== A sample parameter value is given below
            {
              "user_id": "20",
              "unit_id": "12",
              "amount": "100",
              "reason": " pay cash "
              "device_id": "YOTTO05",
              "recorded_at":"2016-02-20 10:50",
              "bill_serial_no": "12-POS2-65",
              "cash_in_descriptions_attributes": [{
                "denomination_id" : "1",
                "count" : "2"
              }]
            }
          EOS
        formats ['json']
        error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
        description <<-EOS
        EOS
      example '
      Success Response (POST Request: http://dev.selfordering.com/api/v2/cash_handlings?device_id=YOTTO05)
        {
          "status": "ok",
          "messages": {
            "simple_message": "Cashin successfully created",
            "internal_message": "Cashin successfully created"
          },
          "data": {
            "id": 100,
            "user_id": 20,
            "unit_id": 12,
            "amount": "1000.0",
            "reason": " pay cash "
            "device_id": "YOTTO05",
            "recorded_at": "2018-02-20T10:50:00+05:30",
            "bill_serial_no": "12-POS2-65",
            "descriptions": [
            {
              "id": 31,
              "cash_in_id": 33,
              "denomination_id": 1,
              "count": 2,
              "image": "/images/original/missing.png",
              "name": "hundred",
              "value": 100
            }
            ]
          }
        }
      '
      ### => 'create' API 
      def cash_in
        ActiveRecord::Base.transaction do
          @cash_in = CashIn.new(params[:cash_in])
          @cash_in.save
        end
        rescue Exception => e
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :POST, '/api/v2/cash_handlings/cash_out', "API to generate a cash out. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :cash_out, Hash, :required => true, :desc => <<-EOS
          ==== A sample parameter value is given below
            {
              "user_id": "20",
              "unit_id": "12",
              "amount": "100",
              "reason": " pay cash "
              "device_id": "YOTTO05",
              "recorded_at":"2016-02-20 10:50",
              "cash_out_descriptions_attributes": [{
                "denomination_id" : "2",
                "count" : "3"
              }]
            }
          EOS
        formats ['json']
        error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
        description <<-EOS
        EOS
      example '
      Success Response (POST Request: http://dev.selfordering.com/api/v2/cash_handlings?device_id=YOTTO05)
        {
          "status": "ok",
          "messages": {
            "simple_message": "Cashin successfully created",
            "internal_message": "Cashin successfully created"
          },
          "data": {
            "id": 100,
            "user_id": 20,
            "unit_id": 12,
            "amount": "100.0",
            "reason": " pay cash "
            "device_id": "YOTTO05",
            "recorded_at": "2018-02-20T10:50:00+05:30",
            "bill_serial_no": "12-POS2-65",
            "descriptions": [
            {
                "id": 5,
                "cash_out_id": 5,
                "denomination_id": 2,
                "count": 3,
                "image": "/images/original/missing.png",
                "name": "hundred",
                "value": 100
            }
            ]
          }
        }
      '
      def cash_out
        ActiveRecord::Base.transaction do
          _pay_update =PayUpdate.current_cash(params[:cash_out][:unit_id])
          if _pay_update >= params[:cash_out][:amount].to_f
            @cash_out = CashOut.new(params[:cash_out])
            @cash_out.save
          else
            @validation_errors = "insufficient cash"
          end 
        end
        rescue Exception => e
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end 
