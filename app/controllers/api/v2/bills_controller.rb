module Api
  module V2
    class BillsController < ApplicationController

      before_filter :authenticate_user_with_token!
      before_filter :set_timerange, only: [:index]
      before_filter :set_default_resources
      load_and_authorize_resource
      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/bills', "List of all bills. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "Filter bills of an unit"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :from_date, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`from_date` parameter is dependent on `to_date` parameter"
      param :to_date, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`to_date` parameter is dependent on `from_date` parameter"
      #param :status, String, :required => false, :desc => "Filter response with bill status."
      param :from_price, String, :required => false, :desc => "This parameter can be used to get results between two price range.", :meta => "`from_date` parameter is dependent on `to_price` parameter"
      param :to_price, String, :required => false, :desc => "This parameter can be used to get results between two price range.", :meta => "`to_date` parameter is dependent on `from_price` parameter"
      param :deliverable_type, String, :required => false, :desc => "Filter response by deliverable type."
      param :deliverable_id, String, :required => false, :desc => "Filter response by deliverable id."
      param :resource_type, String, :required => false, :desc => "Filter response by resource type."
      param :last_bill_id, String, :required => false, :desc => "Last bill id of the device."
      param :pagination, String, :required => false, :desc => "if you want pagination then set this params", :meta => "`pagination` value must be yes"
      param :by_customer, String, :required => false, :desc => "Get bill of the customer"
      param :resources, String, :desc => "This parameter defines, how many extra resources, associated with bill will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :required => false, :meta => {:allowed_resources => ["order_items","tax_details","discount_details","payment_details","delivery_details"], :example => "resources=tax_details,order_items "}

      ### => 'index' API Defination
      def index
        _unit_id = params[:unit_id].present? ? params[:unit_id] : @current_user.unit_id
        _per = params[:count] || 20
        @bills = Bill.order('id desc')
        @bills = @bills.by_date_range(@from_datetime,@to_datetime) if params[:from_date].present?
        @bills = @bills.where("orders.source" => params[:order_source]) if params[:order_source].present?
        @bills = @bills.check_bill_status(params[:status]) if params[:status].present?
        @bills = @bills.set_deliverable_type(params[:deliverable_type].camelize) if params[:deliverable_type].present?
        @bills = @bills.set_deliverable_id(params[:deliverable_id]) if params[:deliverable_id].present?
        @bills = @bills.by_resource_type(params[:resource_type]) if params[:resource_type].present?
        @bills = @bills.check_price_range(params[:from_price],params[:to_price]) if params[:from_price].present? && params[:to_price].present?
        @bills = @bills.greater_than_id(params[:last_bill_id]) if params[:last_bill_id].present?
        @bills = @bills.by_customer(params[:customer_id]) if params[:customer_id].present?
        @count = @bills.count
        @bills = @bills.page(params[:page]).per(_per) if params[:page].present?
        @resources = params[:resources].present? ? params[:resources].split(',') : Array.new
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def show
        @bill = Bill.find(params[:id])
        @resources = params[:resources].present? ? params[:resources].split(',') : ["order_items","tax_details","discount_details","payment_details","delivery_details"]
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/bills', "API to generate a bill. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :bill, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "biller_id":"4",
              "biller_type":"user",
              "serial_no":"100-10-22",
              "pax":"4",
              "unit_id":"5",
              "deliverable_type":"Resource",
              "deliverable_id":"2",
              "customer_id":"123",
              "resource_type":"table",
              "recorded_at":"2016-04-02 11:50",
              "section_id" : "2",
              "bill_destination_id" : "1",
              "lite_device_id" : "234",
              "is_service_charge" : "yes",
              "suffix" : "IFB",
              "prefix" : "CMS",
              "proforma_id" : "12",
              "bill_orders_attributes":[
                {
                "order_id":"3164"
                }
              ],
              "bill_discounts_attributes":[
                {
                  "discount_amount":"10000",
                  "remarks":"OFF20 APPLIED",
                  "is_merchant_discount":"true"
                }
              ]
            }
            "item_discount_attributes":[
              {
                "order_id":"9890",
                "order_details_attributes": [{
                  "id":"14938",
                  "discount":"100",
                  "menu_product_id":"4141",
                  "quantity":"2",
                  "item_status":"item_discount",
                  "remarks":"discount"
                  }]
              }
            ]
        EOS
      formats ['json']
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      description <<-EOS
        EOS
      example '
      Success Response (POST Request: http://dev.selfordering.com/api/v2/bills?device_id=YOTTO05)
        {
          "status": "ok",
          "messages": {
            "simple_message": "Bill generated.",
            "internal_message": "Bill generated."
          },
          "data": {
            "id": 2207,
            "serial_no": "100-10-22",
            "device_id": null,
            "bill_amount": 120.0,
            "tax_amount": 74.36,
            "discount": 194.36,
            "roundoff": 0.0,
            "grand_total": 0.0,
            "unit_id": 5,
            "status": "unpaid",
            "pax": 4,
            "remarks": null,
            "created_at": "2016-03-11T19:00:35+05:30",
            "updated_at": "2016-03-11T19:00:35+05:30",
            "biller_id": 4,
            "section_id": 2,
            "biller_type": "User",
            "biller_name": "Shyam Raha",
            "bill_destination_id" : "1",
            "suffix" : "IFB",
            "prefix" : "CMS",
            "proforma_id" :"12",
            "lite_device_id" : "234",
            "orders": [
              {
                "id": 3164,
                "unit_id": 5,
                "source": "zomato",
                "device_id": "YOTTO05",
                "consumer_id": 4,
                "consumer_type": "User",
                "deliverable_id": 2,
                "deliverable_type": "Section",
                "order_status_id": 2,
                "order_total_without_tax": 120.0,
                "total_tax": 74.36,
                "total_discount": 0.0,
                "order_subtotal": 194.36,
                "trash": 0,
                "cancel_cause": null,
                "created_at": "2016-02-26T18:09:16+05:30",
                "updated_at": "2016-03-11T19:00:35+05:30",
                "order_items": [
                  {
                    "id": 6213,
                    "product_id": 60,
                    "menu_product_id": 343,
                    "product_name": "Chicken 65",
                    "product_price": 120.0,
                    "customization_price": 0.0,
                    "unit_price_without_tax": 120.0,
                    "tax_amount": 74.36,
                    "unit_price_with_tax": 194.36,
                    "discount": 0.0,
                    "quantity": 1,
                    "subtotal": 194.36,
                    "trash": 0,
                    "cancel_cause": null,
                    "bill_status": null,
                    "remarks": null,
                    "status": "approved",
                    "sort_id": 2,
                    "created_at": "2016-02-26T18:09:16+05:30",
                    "updated_at": "2016-02-26T18:09:16+05:30",
                    "product_unit": "Pc",
                    "bill_destination_id" : 12,
                    "customizations": []
                  }
                ]
              }
            ],
            "taxes": [
              {
                "tax_amount": 6.96,
                "tax_class_name": "Service Tax",
                "tax_class_type": "simple",
                "tax_class_amount": 5.8,
                "tax_class_amount_type": "percentage"
              }
            ],
            "discounts": [
              {
                "discount_amount": 194.36,
                "remarks": "OFF20 APPLIED",
                "is_merchant_discount" : "true"
              }
            ],
            "settlement": {}
          }
        }

      Error Response (POST Request: http://dev.selfordering.com/api/v2/bills?device_id=YOTTO05)
        {
          "status": "error",
          "messages": {
            "simple_message": "Something went wrong, try after sometime",
            "internal_message": "Order ID 3164, already billed."
          },
          "data": {}
        }
      '
      ### => 'create' API
      def create
        ActiveRecord::Base.transaction do
          @bill = Bill.find_by_serial_no(params[:bill][:serial_no]) if params[:bill][:serial_no].present?
          unless @bill.present?
            if params[:item_discount_attributes].present?
              params[:item_discount_attributes].each do |discount|
                order = {}
                order_details = []
                discount["order_details_attributes"].each do |count|
                  o_detail = OrderDetail.find(count["id"])
                  _discount = o_detail.discount.to_f + count["discount"].to_f
                  details_hash = {}
                  if count["discount"].to_f == o_detail.unit_price_without_tax.to_f * o_detail.quantity
                    details_hash["id"]        = count["id"]
                    details_hash["quantity"]  = o_detail.quantity
                    details_hash["menu_product_id"] = o_detail.menu_product_id
                    details_hash["remarks"] = count["remarks"]
                    details_hash["discount"] = _discount
                    details_hash["bill_status"] = "no_charge"
                  else
                    details_hash["id"]        = count["id"]
                    details_hash["quantity"]  = o_detail.quantity
                    details_hash["menu_product_id"] = o_detail.menu_product_id
                    details_hash["remarks"] = count["remarks"]
                    details_hash["discount"] = _discount
                    details_hash["item_status"] = "item_discount"
                  end  
                  order_details.push details_hash
                  order["order_details_attributes"] = order_details
                end
                @order = Order.find(discount["order_id"])
                @order.update_attributes(order)
              end
            end  
          end
          @bill = Bill.new(params[:bill]) unless @bill.present?
          _order = @bill.bill_orders.first.order
          @bill = _order.bill if _order.billed? # Return bill if order already billed
          if @bill.new_record? and @bill.save
            @bill.reload
          else  
            @validation_errors = error_messages_for(@bill)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'update' action
      api :PUT, '/api/v2/bills/:id', "API to update a bill. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :bill, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
               "status":"cod",
               "is_service_charge" : "no",
               "bill_discounts_attributes":[
                  {
                     "discount_amount":"10",
                     "remarks":"OFF10"
                  }
               ]
            }
          ==== A sample parameter value is given below for bill splite by_product
              {
                "bill_splits_attributes": [
                  {
                    "user_id": "20",
                    "unit_id": "12",
                    "split_type": "by_product",
                    "checksum": "123er",
                    "bill_split_products_attributes": [
                      {
                        "order_detail_id": "196326"
                        "quantity":"1"
                      },
                      {
                        "order_detail_id": "196327"
                        "quantity":"1"
                      }
                    ]
                  },
                  {
                    "user_id": "20",
                    "unit_id": "12",
                    "split_type": "by_product",
                    "checksum": "123er",
                    "bill_split_products_attributes": [
                      {
                        "order_detail_id": "196328"
                        "quantity":"1"
                      },
                      {
                        "order_detail_id": "196329"
                        "quantity":"1"
                      }
                    ]
                  }
                ]
              }

          ==== A sample parameter value is given below for bill splite by_amount

            {
              "bill_splits_attributes": [
                {
                  "user_id": "20",
                  "unit_id": "12",
                  "split_type": "by_amount",
                  "grand_total": "150",
                  "checksum": "123er"
                },
                {
                  "user_id": "20",
                  "unit_id": "12",
                  "split_type": "by_amount",
                  "grand_total": "162",
                  "checksum": "123er"
                }
              ]
            }
        EOS
      # param :item_discount_attributes, Hash, :required => false, :desc => <<-EOS
      #   [{
      #     "order_id":"9890",
      #     "order_details_attributes": [{
      #       "id":"14938",
      #       "discount":"100",
      #       "menu_product_id":"4141",
      #       "quantity":"2",
      #       "item_status":"item_discount",
      #       "remarks":"discount"
      #       }]
      #   }]
      # EOS  
      formats ['json']
      description <<-EOS
        Response of this API is same as `create` api.
        EOS
      ### => 'update' API
      def update
        ActiveRecord::Base.transaction do
          @bill = Bill.find(params[:id])

          if params[:item_discount_attributes].present?
            params[:item_discount_attributes].each do |discount|
              order = {}
              order_details = []
              discount["order_details_attributes"].each do |count|
                o_detail = OrderDetail.find(count["id"])
                o_detail.update_column(:item_status, "")
                _discount = count["discount"].to_f # + o_detail.discount.to_f  COMMANT BY ABDUL
                details_hash = {}
                if count["discount"].to_f == o_detail.unit_price_without_tax.to_f * o_detail.quantity
                  details_hash["id"]        = count["id"]
                  details_hash["quantity"]  = o_detail.quantity
                  details_hash["menu_product_id"] = o_detail.menu_product_id
                  details_hash["remarks"] = count["remarks"]
                  details_hash["bill_status"] = "no_charge"
                else
                  details_hash["id"]        = count["id"]
                  details_hash["quantity"]  = o_detail.quantity
                  details_hash["menu_product_id"] = o_detail.menu_product_id
                  details_hash["remarks"] = count["remarks"]
                  details_hash["discount"] = _discount
                  details_hash["item_status"] = "item_discount"
                end  
                order_details.push details_hash
                order["order_details_attributes"] = order_details
              end
              @order = Order.find(discount["order_id"])
              @order.update_attributes(order)
            end
          end  
          if params[:bill][:is_service_charge] == "no"
            @bill.remove_service_charge
          end  
          if @bill.update_attributes(params[:bill])
            @bill.reload
          else
            @validation_errors = error_messages_for(@bill)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end 

      api :GET, '/api/v2/bills/find_bill_by_serial', "Find bill by serial no. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :serial_no, String, :required => true, :desc => "serial_no of the bill"
      param :resources, String, :desc => "This parameter defines, how many extra resources, associated with bill will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :required => false, :meta => {:allowed_resources => ["order_items","tax_details","discount_details","payment_details","delivery_details"], :example => "resources=tax_details,order_items "}
      def find_bill_by_serial
        @bill = Bill.find_by_serial_no(params[:serial_no])
        @resources = params[:resources].present? ? params[:resources].split(',') : ["order_items","tax_details","discount_details","payment_details","delivery_details"]
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'bill_on_hold' action
      api :PUT, '/api/v2/bills/bill_on_hold', "API for bill on hold. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :boh_settlement, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "bill_id": "9734",
              "payble_amount": "1400",
              "boh_amount": "800",
              "user_id": "3",
              "unit_id": "7",
              "split_type": "by_amount",
              "client_type":"User",
              "device_id" : "YOTTO05",
              "tips": 0,
              "recorded_at": "2016-04-02 11:50",
              "boh_settlements_attributes":
                {
                  "payments_attributes": [
                    {
                      "paymentmode_type": "ThirdPartyPayment",
                      "paymentmode_attributes": {
                        "third_party_payment_option_id": "1",
                        "amount": "1400"
                      }
                    }
                  ]
                }
              
            }
        EOS

      def bill_on_hold
        @bill = Bill.find(params[:boh_settlement][:bill_id])
        @bill.update_column(:status,'boh')
        payble_amount = params[:boh_settlement][:payble_amount]
        boh_amount = params[:boh_settlement][:boh_amount]
        split_amounts = [boh_amount,payble_amount]
        split_amounts.each do |split_amount|
          @new_split = BillSplit.new(:bill_id=>params[:boh_settlement][:bill_id],:grand_total=>split_amount, :split_type=>params[:boh_settlement][:split_type], :unit_id=>params[:boh_settlement][:unit_id], :user_id=>params[:boh_settlement][:user_id],:biller_id => params[:boh_settlement][:user_id])
          @new_split.save
        end
        @settlement = Settlement.new(boh_settlements_params(@new_split.id))
        if @settlement.save
          @settlement.reload
        end

        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

      def set_default_resources
        @resources = params[:resources].present? ? params[:resources].split(',') : ["order_items","tax_details","discount_details","payment_details","delivery_details"]
      end

      def boh_settlements_params(bill_split_id)
        {
          "bill_id"       => params[:boh_settlement][:bill_id],
          "client_id"     => params[:boh_settlement][:user_id],
          "client_type"   => params[:boh_settlement][:client_type],
          "tips"          => params[:boh_settlement][:tips],
          "recorded_at"   => params[:boh_settlement][:recorded_at],
          "device_id"     => params[:boh_settlement][:device_id],
          "split_settlements_attributes"     => [
            {
              "bill_split_id"             => bill_split_id,
              "payments_attributes"       => params[:boh_settlement][:boh_settlements_attributes][:payments_attributes]
            }
          ]
        }
      end

    end
  end
end
