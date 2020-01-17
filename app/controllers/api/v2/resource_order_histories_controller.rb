module Api
  module V2
    class ResourceOrderHistoriesController < ApplicationController
      require 'json'
      before_filter :authenticate_user_with_token!
      before_filter :set_timerange, only: [:index]

      load_and_authorize_resource

      ## => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/resource_order_histories', "List of all resource_order_histories. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => false, :desc => "Filter orders of an unit"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :user_id, String, :required => false, :desc => "Filter response by User."
      param :resource_id, String, :required =>false, :desc => "Filter Orders by Resource"
      

      ### => 'index' API Defination
      def index
        _per = params[:count] || 20
        @resource_orders = ResourceOrderHistory.order('id desc')
        @resource_orders = @resource_orders.by_unit(params[:unit_id]) if params[:unit_id].present?
        @resource_orders = @resource_orders.by_resource(params[:resource_id]) if params[:resource_id].present?
        @resource_orders = @resource_orders.by_user(params[:user_id]) if params[:user_id].present?
        @count  = @resource_orders.count
        @resource_orders = @resource_orders.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/resource_order_histories', "API to place new order. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :resource_order_history, Hash, :required => true, :desc => <<-EOS
          ==== A sample parameter value is given below
            {
              "resource_id":"12",
              "unit_id":"3"
              "user_id":"12",
              "recorded_at":"2016-04-02 11:50",
              "latitude": "12.3412",
              "longitude": "12.3454",
              "device_id": "1234",
              "resource_order_history_details_attributes":[
                {
                  "menu_product_id":"327",
                  "remarks": "order only",
                  "quantity":"1"
                }
              ]  
            }
        EOS
      formats ['json']
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      description <<-EOS
        EOS
      example '
      Success Response (POST Request: http://dev.selfordering.com/api/v2/resource_order_histories?device_id=YOTTO05)
        {
          "status": "ok",
          "messages": {
            "simple_message": "Resource order history saved successfuly",
            "internal_message": "Resource order history saved successfuly"
          },
          "data": {
            "id": 12,
            "latitude": "12.3412",
            "longitude": "12.3454",
            "recorded_at": "2016-04-02T11:50:00Z",
            "resource_id": 12,
            "unit_id": 3,
            "user_id": 12,
            "device_id": "1234",
            "resource_order_history_items": [{
              "id": 12,
              "product_id": 344,
              "menu_product_id": 4135,
              "product_name": "napkin",
              "remarks": "order only",
              "created_at": "2019-05-09T20:40:16Z",
              "updated_at": "2019-05-09T20:40:16Z"
            }]
          }
        }

      Error Response (POST Request: http://dev.selfordering.com/api/v2/resource_order_histories?device_id=YOTTO05)

        {
          "status": "error",
          "messages": {
            "simple_message": "Something went wrong while placing new order",
            "internal_message": "Some items (Tomato Soup) or its ingredients (Tomato, Garlic, Corn Flour) in this order have insufficient stock."
          },
          "data": {}
        }
      '
      ### => 'create' API

      def create
        ActiveRecord::Base.transaction do
          @resource_order = ResourceOrderHistory.new(params[:resource_order_history])
          unless @resource_order.new_record? and @resource_order.save
            @validation_errors = error_messages_for(@resource_order)
          else
            @resource_order = @resource_order.reload
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? #Log exception
      end
      
      ### => API Documentation (APIPIE) for 'show' action
      api :GET, '/api/v2/orders/:id', "API to fetch a order.(Authorization header required for authentication)"
      param :email, String, :required => false, :desc => "Email ID of user, who is show the order."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :resources, String, :desc => "This parameter defines, how many extra resources, associated with orders will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :required => false, :meta => {:allowed_resources => ["delivery_details","order_items","bill_details"], :example => "resources=delivery_details,order_items,order_slots "}
      def show
        @order = Order.find(params[:id])
        @resources = params[:resources].present? ? params[:resources].split(',') : ["order_items","delivery_details","bill_details","order_slots"]
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end
