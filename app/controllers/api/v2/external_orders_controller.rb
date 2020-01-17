module Api
  module V2
    class ExternalOrdersController < ApplicationController

    	# load_and_authorize_resource

      require 'rest-client'
      require 'json'

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/external_orders', "List of all External orders."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :by_order_source, String, :required => false, :desc => "Get external orders of the order source."
      param :by_order, String, :required => false, :desc => "Get external orders by the order id."
      param :by_external_order, String, :required => false, :desc => "Get external orders by the external order id."
      param :by_unit, String, :required => false, :desc => "Get external orders by the unit id."
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"

      ### => 'index' API Defination
      def index
        # _unit_id = params[:unit_id].present? ? params[:unit_id] : @current_user.unit_id
        _per = params[:count] || 20
        @external_orders = ExternalOrder.order('id desc')
        @external_orders = @external_orders.where("external_orders.order_source" => params[:by_order_source]) if params[:by_order_source].present?
        @external_orders = @external_orders.where("external_orders.order_id" => params[:by_order]) if params[:by_order].present?
        @external_orders = @external_orders.where("external_orders.external_order_id" => params[:by_external_order]) if params[:by_external_order].present?
        @external_orders = @external_orders.where("external_orders.unit_id" => params[:by_unit]) if params[:by_unit].present?
        @count = @external_orders.count
        @external_orders = @external_orders.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
      
      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/external_orders', "API to place new External order. (Authorization header required for authentication) This order will call by thirdparty (Urbanpiper)."
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the external order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :order_source, String, :required => true, :desc => "External order source i.e. zomato, urban_piper, foodpanda etc."
      param :order, Hash, :required => false, :desc => "The JSON Format of external order for different sources are different."
      param :customer, Hash, :required => false, :desc => "The JSON Format of customer for different sources are different it can also added with order json then the customer parms will null."
      ### => 'create' API

      def create
        ActiveRecord::Base.transaction do
          @ext_order = ExternalOrder.new
          if params[:order_source] == "urban_piper" ## URBANPIPER START
            @ext_order.order_source = params[:order_source]
            @ext_order.order = params[:order].to_json
            @ext_order.customer = params[:customer].to_json
            @ext_order.external_order_id = params[:order][:details][:id]

            @ext_customer = params[:customer]
            if @ext_order.save
              render json: {:status=>'ok', :message => {:simple_message=>"External Order placed successfully.", :internal_message=>"External Order placed successfully."}, :customer=> params[:customer].to_json, :order=> params[:order].to_json}
            else
              render json: {:status=>"error", :messages => {:simple_message=>"Something went wrong while placing new external order", :internal_message=>"Something went wrong while placing new external order." }, :customer=> {}, :order=> {}}
            end
          elsif params[:order_source] == "zomato" ## URBANPIPER END & ZOMATO START
            @ext_order.order_source = params[:order_source]
            @ext_order.order = params[:order].to_json
            @ext_order.external_order_id = params[:order][:order_id]

            if @ext_order.save
              render json: {:status=>'success', :message => "Zomato external order placed successfully.",:code => 200 , :order=> params[:order].to_json}
            else
              render json: {:status=>"failed", :message => "Something went wrong while placing new zomato external order.",:code => 500, :order=> {}}
            end
          end   ## ZOMATO END
        end
      end


      ### => API Documentation (APIPIE) for 'set_status' action 
      api :POST, '/api/v2/external_orders/set_status', "API to set status to External order. (Authorization header required for authentication) This API will call by thirdparty (Urbanpiper)."
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the external order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :order_source, String, :required => true, :desc => "External order source i.e. zomato, urban_piper, foodpanda etc."
      param :order_id, Integer, :required => false, :desc => "External order id."
      param :message, String, :required => false, :desc => "Order status message/reason."
      param :new_state, String, :required =>false, :desc => "Order status/action."
      param :reason, String, :required => false, :desc => "Order status message/reason."
      param :action, String, :required =>false, :desc => "Order status/action."
      ### => 'set_status' API

      def set_status
        ActiveRecord::Base.transaction do
          @ext_order = ExternalOrder.find_by_external_order_id(params[:order_id].to_s)
          _order_id = @ext_order.order_id
          if @ext_order.present? && @ext_order.order_source == "urban_piper"    ### URBANPIPER
            @ext_order.update_attributes(:thirdparty_status =>  params[:new_state])
            _order = Order.find(_order_id)
            if _order.present?
              if params[:new_state].downcase=="cancelled"
                OrderManagement::cancel_order(_order_id, params[:message])
              elsif params[:new_state].downcase=="confirm"
                _order.update_attributes(:order_status_id => 1)
              elsif params[:new_state].downcase=="acknowledged"
                _order.update_attributes(:order_status_id => 2)
              elsif params[:new_state].downcase=="confirmed"
                _order.update_attributes(:order_status_id => 3)
              elsif params[:new_state].downcase=="food ready"
                _order.update_attributes(:order_status_id => 4)
              elsif params[:new_state].downcase=="dispatched"
                _order.update_attributes(:order_status_id => 5)
              elsif params[:new_state].downcase=="completed"
                _order.update_attributes(:order_status_id => 6)
              end
            end
            render json: {:status=>'ok', :message => {:simple_message=>"External Order status changed successfully.", :internal_message=>"External Order status changed successfully."}}
          elsif @ext_order.present? && @ext_order.order_source == "zomato"     ### ZOMATO
            # if params[:action]=="timeout" || params[:action]=="reject"
            OrderManagement::cancel_order(@ext_order.order_id, params[:reason])
            # end
            @ext_order.update_attributes(:thirdparty_status =>  "Cancelled")
            render json: {:status=>'ok', :message => {:simple_message=>"External Order status changed successfully.", :internal_message=>"External Order status changed successfully."}}
          else
            render json: {:status=>"error", :messages => {:simple_message=>"Something went wrong while changing status external order.", :internal_message=>"Something went wrong while changing status external order." }}
          end
        end
      end

      ### => API Documentation (APIPIE) for 'set_status_to_thirdparty' action 
      api :PUT, '/api/v2/external_orders/:id', "API to set status to External order. (Authorization header required for authentication)."
      param :email, String, :required => true, :desc => "Email ID of user, who is placing the external order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :new_status, String, :required => true, :desc => "New order status (Acknowledged, Food Ready, Cancelled)."

      ### => 'update' API

      def update
        begin
          ActiveRecord::Base.transaction do
            @ext_order = ExternalOrder.find(params[:id]) 
            if @ext_order.present? && @ext_order.order_source == "urban_piper"
              @status_hash={}
              @status_hash["new_status"] = params[:new_status]
              @status_hash["message"] = nil
              @res=ThirdpartyUrbanpiper.thirdparty_urbanpiper_order_status(@ext_order.external_order_id,@status_hash.to_json)
              if @res==true
                @ext_order.update_attributes(:thirdparty_status => params[:new_status])
                render json: {:status=>'ok', :message => {:simple_message=>"External Order status changed successfully.", :internal_message=>"External Order status changed successfully."}}
              else
                render json: {:status=>"error", :messages => {:simple_message=>"Something went wrong while changing status external order.", :internal_message=>"Something went wrong while changing status external order." }}
              end 
            else
              render json: {:status=>"error", :messages => {:simple_message=>"Something went wrong while changing status external order.", :internal_message=>"Something went wrong while changing status external order." }}
            end
          end
        rescue Exception => e
        @log = Rscratch::Exception.log(@error,request) if @error.present?
        end
      end

      private
      def customer_params      
        { 
          "email"                         => params[:customer][:email],
          "mobile_no"                     => params[:customer][:phone],
          "password"                      => "12345678",
          "gstin"                         => "",
          "business_type"                 => "",
          "fb_id"                         => "",

          "customer_profile_attributes" =>
          {
            "firstname" => params[:customer][:name],
            "lastname" => params[:customer][:name],
            "contact_no" => params[:customer][:phone],
            "address" => params[:customer][:address][:city]+", PIN - "+params[:customer][:address][:pin],
            "gender" => "",
            "age" => "",
            "dob" => "",
            "anniversary" => "",
            "picture_url" => "",
            "profile_url" => ""
          }      
        }
      end

      def order_params
        {

        }
      end
    end
	end
end