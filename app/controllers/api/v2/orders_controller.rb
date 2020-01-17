module Api
  module V2
    class OrdersController < ApplicationController
      require 'json'
      before_filter :authenticate_user_with_token!
      before_filter :set_timerange, only: [:index]

      load_and_authorize_resource

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/orders', "List of all orders. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => false, :desc => "Filter orders of an unit"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :from_date, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`from_date` parameter is dependent on `to_date` parameter"
      param :to_date, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`to_date` parameter is dependent on `from_date` parameter"
      param :status, String, :required => false, :desc => "Status ID is required to filter response with order status."
      param :source, String, :required => false, :desc => "Filter response by order source."
      param :deliverable_type, String, :required => false, :desc => "Filter response by deliverable type."
      param :delivery_boy_id, String, :required => false, :desc => "Filter response by delivery boy."
      param :deliverable_id, String, :required => false, :desc => "Filter response by deliverable id."
      param :resource_type, String, :required => false, :desc => "Filter response by resource type."
      param :client_type, String, :required => false, :desc => "Filter response by client(Who placed the order) type ."
      param :client_id, String, :required => false, :desc => "Filter response by client id."
      param :deliverable_ids, Array, :required =>false, :desc => "Filter response by multiple delivarable ids"
      param :status_ids, Array, :required => false, :desc => "Order status ids"
      param :deliverable_types, Array, :required => false, :desc => "Filter response by deliverable types."
      param :bill_status, String, :required => false, :desc => "Filter only billed (value: 1) or unbilled orders (value: 0)."
      param :cancelation_status, String, :required => false, :desc => "Filter orders by cancelation status. value: `1` to get cancled orers and value: `0` to get confirmed orders."
      param :customer_queue_id, String, :required => false, :desc => "Reservation customer queue id"
      param :customer_id, String, :required =>false, :desc => "Filter Orders by Customer"
      param :operation_type, String, :required => false, :desc => "Filter orders by operation_type. value: `b2b` to get b2b orers and value: `b2c` to get b2c orders."
      param :has_proforma, String, :required => false, :desc => "Filter orders by has_proforma. value: `1` to get proformad orders and value: `0` to get not proforma orders."
      param :delivery_date, String, :required =>false, :desc => "Filter Orders by delivary date"
      param :pagination, String, :required => false, :desc => "if you want pagination then set this params", :meta => "`pagination` value must be yes"
      param :resources, String, :desc => "This parameter defines, how many extra resources, associated with orders will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :required => false, :meta => {:allowed_resources => ["delivery_details","order_items","unit_info","item_tax"], :example => "resources=delivery_details,order_items,unit_info"}
      param :external_order, String, :required => false, :desc => "To get all external orders please set this params as string true."
      param :reservation_id, String, :required => false, :desc => "order of the reservation"
      ### => 'index' API Defination
      def index
        _per = params[:count] || 20
        @orders = Order.order('id desc')
        @orders = @orders.by_date_range(@from_datetime,@to_datetime) if params[:from_date].present? and params[:to_date].present?
        @orders = @orders.by_unit_id(params[:unit_id]) if params[:unit_id].present?
        @orders = @orders.by_status(params[:status]) if params[:status].present?
        @orders = @orders.check_order_status(params[:status_ids]) if params[:status_ids].present?
        @orders = @orders.by_source(params[:source]) if params[:source].present?
        @orders = @orders.by_deliverable_type(params[:deliverable_type].camelize) if params[:deliverable_type].present?
        @orders = @orders.by_deliverable_id(params[:deliverable_id]) if params[:deliverable_id].present?
        @orders = @orders.by_consumer_type(params[:consumer_type]) if params[:consumer_type].present?
        @orders = @orders.by_consumer_id(params[:consumer_id]) if params[:consumer_id].present?
        @orders = @orders.by_billed_status(params[:bill_status]) if params[:bill_status].present?
        #@orders = @orders.by_trash(0) if params[:bill_status].present?
        @orders = @orders.by_trash(params[:cancelation_status]) if params[:cancelation_status].present?
        @orders = @orders.by_resource_type(params[:resource_type]) if params[:resource_type].present?
        #@orders = @orders.by_trash(0) if params[:status].present?
        @orders = @orders.external? if params[:external_order].present? && params[:external_order] == "true"
        @orders = @orders.by_trash(params[:cancelation_status]) if params[:cancelation_status].present?
        @orders = @orders.check_order_deliverable_id(params[:deliverable_ids]) if params[:deliverable_ids].present?
        @orders = @orders.check_deliverable_types(params[:deliverable_types]) if params[:deliverable_types].present?
        @orders = @orders.by_customer_queue(params[:customer_queue_id]) if params[:customer_queue_id].present?
        @orders = @orders.order_by_delivery_boy_id(params[:delivery_boy_id]) if params[:delivery_boy_id].present?
        @orders = @orders.by_customer(params[:customer_id]) if params[:customer_id].present?
        @orders = @orders.by_operation_type(params[:operation_type]) if params[:operation_type].present?
        @orders = @orders.by_has_proforma(params[:has_proforma]) if params[:has_proforma].present?
        @orders = @orders.by_delivery_date(params[:delivery_date]) if params[:delivery_date].present?
        @orders = @orders.reservation_orders(params[:reservation_id]) if params[:reservation_id].present?
        @count  = @orders.count
        @orders = @orders.page(params[:page]).per(_per) if params[:page].present?
        @resources = params[:resources].present? ? params[:resources].split(',') : Array.new
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/orders', "API to place new order. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :order, Hash, :required => true, :desc => <<-EOS
          ==== A sample parameter value is given below
            {
              "deliverable_type":"Resource",
              "resource_type":"table"
              "consumer_type":"user",
              "consumer_id":"4",
              "order_status_id":"2",
              "order_sr_no":"100",
              "deliverable_id":"2",
              "device_id":"YOTTO05",
              "source":"zomato",
              "unit_id":"5",
              "delivary_date":"2016-04-02 11:50",
              "recorded_at":"2016-04-02 11:50",
              "lite_device_id":"1234",
              "customer_id": 123,
              "latitude": "12.3412",
              "longitude": "12.3454",
              "address_id": "1",
              "third_party_order_id":"123"
              "order_details_attributes":[
                {
                  "menu_product_id":"327",
                  "quantity":"1",
                  "lot_id":"2",
                  "checksum":"123wer#567",
                  "preferences":"Low chilli",
                  "parcel":"0",
                  "product_unique_identity":"12345",
                  "expiry_date":"2017-06-16",
                  "delivery_status":1,
                  "item_remarks":"some text",
                  "item_preference" : "No salt"
                  "order_detail_combinations_attributes":[
                    {
                    "menu_product_combination_id":"388",
                    "combination_qty":"1"
                    }
                  ],
                  "order_details_combos_attributes":[
                    {
                    "combo_item_id":"388"
                    },
                    {
                    "combo_item_id":"389"
                    },
                    {
                    "combo_item_id":"390"
                    }
                  ]
                },
                {
                  "menu_product_id":"343",
                  "quantity":"1",
                  "preferences":"no salt",
                  "parcel":"0"
                }
              ],
              "order_slots_attributes":[
                {
                  "slot_id": "1",
                  "delivery_date": "2017-06-16"
                }
              ]
            }
        EOS
      formats ['json']
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      description <<-EOS
        EOS
      example '
      Success Response (POST Request: http://dev.selfordering.com/api/v2/orders?device_id=YOTTO05)
        {
          "status": "ok",
          "messages": {
            "simple_message": "Order placed successfully",
            "internal_message": "Order placed successfully"
          },
          "data": {
            "id": 3141,
            "source": "zomato",
            "unit_id": 5,
            "deliverable_id": 2,
            "deliverable_type": "Resource",
            "resource_type":"table"
            "delivery_boy_id": null,
            "trash": 0,
            "cancel_cause": null,
            "delivary_date": "2016-02-25T11:36:11+05:30",
            "created_at": "2016-02-25T11:36:11+05:30",
            "updated_at": "2016-02-25T11:36:12+05:30",
            "consumer_id": 4,
            "consumer_type": "User",
            "consumer_name": "Shyam Raha",
            "lite_device_id":"1234",
            "third_party_order_id":"123"
            "deliverable": {
              "additional_tax": 0.0,
              "created_at": "2015-02-21T11:46:15+05:30",
              "description": "",
              "id": 2,
              "is_trashed": false,
              "more_details": null,
              "name": "dine in",
              "unit_id": 5,
              "updated_at": "2015-02-21T11:46:15+05:30"
            },
            "order_items": [
              {
                "id": 6190,
                "product_id": 43,
                "menu_product_id": 327,
                "product_name": "Tomato Soup",
                "product_price": 50.0,
                "customization_price": 10.0,
                "unit_price_without_tax": 60.0,
                "tax_amount": 62.18,
                "unit_price_with_tax": 122.18,
                "discount": 0.0,
                "quantity": 1,
                "subtotal": 122.18,
                "trash": 0,
                "cancel_cause": null,
                "bill_status": null,
                "remarks": null,
                "status": "approved",
                "sort_id": 2,
                "created_at": "2016-02-25T11:36:11+05:30",
                "updated_at": "2016-02-25T11:36:11+05:30",
                "parcel": 0,
                "product_unique_identity": "12345",
                "expiry_date": "2017-06-16",
                "product_unit": "Pc",
                "delivery_status":1,
                "item_remarks":"some text",
                "bill_destination_id":23,
                "customizations": [
                  {
                    "id": 697,
                    "product_id": 1,
                    "product_name": "Tomato",
                    "product_price": 10.0,
                    "total_price": 10.0,
                    "quantity": 1
                  }
                ]
              }
            ]
          }
        }

      Error Response (POST Request: http://dev.selfordering.com/api/v2/orders?device_id=YOTTO05)

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
          @order = Order.find_by_checksum(params[:order][:checksum]) if params[:order][:checksum].present?
          @order = Order.new(params[:order]) unless @order.present?
          unless @order.new_record? and @order.save
            @validation_errors = error_messages_for(@order)
            @validation_msg = "Duplicate Order"
          else
            @order = @order.reload
            if params[:order][:customer_id].present?
              @order.generate_deliverable_otp
              @order.send_deliverable_otp
            end
          end
        end
        @resources = params[:resources].present? ? params[:resources].split(',') : ["order_items","delivery_details","item_tax"]
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? #Log exception
      end

      ### => API Documentation (APIPIE) for 'cancel_item' action
      api :POST, '/api/v2/orders/cancel_item', "API to calcel an order item. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is canceling the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :order_detail_id, String, :required => true, :desc => "Order detail/item ID which you want to calcel."
      param :cancel_cause, String, :required => true, :desc => "Reason for cancelation."
      param :is_refandable, String, :required => false, :desc => "Money is refundable or not depands on this value", :meta => "`is_refandable` yes or no "
      param :account_no, String, :required => false, :desc => "Bank Account Number of the customer, where the refund will be initiated"
      param :ifsc_code, String, :required => false, :desc => "Bank IFSC code of the customer, where the refund will be initiated"
      formats ['json']
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"

      ### => 'cancel_item' API
      def cancel_item
        @order_item = OrderDetail.find(params[:order_detail_id])
        @order_item.cancel params[:cancel_cause], current_user, params[:is_refandable], params[:account_no], params[:ifsc_code]
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :PUT, '/api/v2/orders/:id', "Update order. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :account_no, String, :required => false, :desc => "Bank Account Number of the customer, where the refund will be initiated. (During Cancel)"
      param :ifsc_code, String, :required => false, :desc => "Bank IFSC code of the customer, where the refund will be initiated. (During Cancel)"
      param :order, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
          {
            "deliverable_type": "Resource",
            "resource_type": "table",
            "deliverable_id": "2",
            "source": "fos",
            "delivary_date": "2017-11-25 11:50",
            "trash": "1",
            "cancel_cause" : "cancel cause",
            "is_refandable" : "yes",
            "order_details_attributes": [
              {
                "id": "14901",
                "menu_product_id": "261",
                "quantity": "2",
                "trash": "1",
                "cancel_cause": "Customer canceled"
              },
              {
                "id": "14902",
                "menu_product_id": "262",
                "quantity": "3"
              }
            ]
          }

        For item no_charge in bill
         {
            "order_details_attributes": [
              {
                "id": "14939",
                "menu_product_id": "4141",
                "quantity": "2",
                "bill_status": "no_charge",
                "remarks": "No chage item"
              }
            ]
          }

        For item hold to go
         {
            "order_details_attributes": [
              {
                "id": "14939",
                "menu_product_id": "4141",
                "delivery_status":0
              }
            ]
          }  
  
        EOS
      formats ['json']

      def update
        begin
          ActiveRecord::Base.transaction do
            @order = Order.find(params[:id]) 
            if @order.update_attributes(params[:order])
              # if params[:order][:trash] == '1' && params[:order][:is_refandable] == 'yes'
              #   Order.refund_money @order.reload, params[:account_no], params[:ifsc_code]
              # end
              # SMS send
              if params[:order][:trash] == '1'
                if AppConfiguration.get_config_value('send_sms_on_status_change') == 'enabled'
                  api_key = 'Q2JRePQw7py'
                  mobile_no = '918250510764'
                  sender_id = 'YOTTOL'
                  service_name = 'TEMPLATE_BASED'
                  api_base_url = "smsapi.24x7sms.com/api_2.0/SendSMS.aspx?APIKEY="
                  
                  unit_name = @order.unit.unit_detail.options[:order_sms_unit_name].present? ? @order.unit.unit_detail.options[:order_sms_unit_name] : @order.unit.unit_name
                  message = 'Your order '+@order.id.to_s+' has been cancelled. Thanks for using '+ unit_name+ '.'
                  message = URI.encode(message)

                  mobile_no = @order.deliverable.customer.profile.contact_no if @order.deliverable_type == "Address"  
                  mobile_no = @order.deliverable.profile.contact_no if @order.deliverable_type == "Customer"    
                  mobile_no ||= @order.customer.profile.contact_no if @order.customer_id.present?
                  mobile_no = "91#{mobile_no}"
                  uri = "http://#{api_base_url}#{api_key}&MobileNo=#{mobile_no}&SenderID=#{sender_id}&Message=#{message}&ServiceName=#{service_name}"
                  rest_response = RestClient.get uri
                end
                # SMS send
                if params[:order][:is_refandable] == 'yes'
                  Order.refund_money @order.reload, params[:account_no], params[:ifsc_code]
                end
                # SMS send
              end  
              @order.reload 
            else
              @validation_errors = error_messages_for(@order)
            end
          end
        rescue Exception => e
        @log = Rscratch::Exception.log(@error,request) if @error.present?
        end
      end
      ### API Documentation (APIPIE) for authenticate deliver by verifying deliverable OTP ########
      api :POST, '/api/v2/orders/verify_deliverable_otp', "API is for authenticate delivery using deliverable PIN code (6 digit OTP) (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of authenticate user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :verify, Hash, :required => true, :desc => <<-EOS
      ==== A sample parameter value is given below
      {
        "order_id":"9927",
        "deliverable_otp":"269512"
      }
      EOS
      formats ['json']
      ################################################
      def verify_deliverable_otp
        @verify_delivery = Order.find("id = ? AND deliverable_otp = ?", params[:verify][:order_id], params[:verify][:deliverable_otp]).first
        if @verify_delivery.present?
          if @verify_delivery.otp_status != true
            @verify_delivery.otp_status = true
            @verify_delivery.save
          else
            @custom_error="otp has already verified"
          end
        else
          @custom_error="otp is wrong"
        end
      end
			## API Documentation (APIPIE) for authenticate deliver by verifying deliverable OTP ########
      api :POST, '/api/v2/orders/resend_deliverable_otp', "API is for resending Deliverable OTP (6 digit OTP) (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of authenticate user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :order_id, String, :required => true, :desc => "order id"

      def resend_deliverable_otp
      	@order= Order.find(params[:order_id])
    		if @order.otp_status == false
    			@order.send_deliverable_otp
      	end
      	rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?
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
