module Api
  module V2
    class StoresController < ApplicationController

    	### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/stores', "List of stores of an unit. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "Stores of this unit"
    	param :store_type, String, :required => false, :desc => "Type of the store"
    	param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
    	param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"

    	### => 'index' API Defination
      def index
        @unit = Unit.find(params[:unit_id])
        _per = params[:count] || 20

         store_ids = []
        @unit.stores.map { |e| store_ids.push e.id } if @unit.present?
        @unit.parent_unit.stores.map { |e| store_ids.push e.id } if @unit.parent_unit.present?
        @stores = Store.set_id_in(store_ids)
        @stores = @stores.by_store_type(params[:store_type]) if params[:store_type].present?
        @stores_count = @stores.count
        @stores = @stores.page(params[:page]).per(_per) if params[:page].present?

        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'get_store_details' action
      api :GET, '/api/v2/stores/find_by_pincode', "Store by pincode. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :pincode, String, :required => true

      def find_by_pincode
        @store_details = Store.find_by_pincode(params[:pincode])
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/stores', "Register new store."
      param :email, String, :required => false, :desc => "Email ID of user, who is registering the user."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :store, Hash, :required => true, :desc => <<-EOS

        ==== A sample parameter value is given below
          {
            "name": "Store1 test1",
            "contact_number": "9009009001",
            "address": "West Bengal",
            "pincode": "700102",
            "store_type": "physical_store",
            "unit_id": "7",
            "store_priority": "primary_store",
            "tin_no": "101",
            "tan_no": "102",
            "latitude": "22.100",
            "longitude": "88.010",
            "gstn_no": "201",
            "pan_no": "202",
            "contact_person": "Pravin Kumar1",
            "user_id": "1"
            }
        EOS
      formats ['json']

      def create
        @store = Store.find_by_contact_number(params[:store][:contact_number])
        if @store.present?
          @status_code = 406
          @status_message = "Store exist with this contact no."
        else
          @store = Store.new(params[:store])
          if @store.save
            @store.reload
          else
            @validation_errors = error_messages_for(@store)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :GET, '/api/v2/stores/store_products', "Store by pincode."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "Store products of this unit"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"

      def store_products
        store_array = []
        _per = params[:count] || 20
        _unit = Unit.find(params[:unit_id])
        @unit_stores = _unit.stores.order("id asc")
        @unit_stores.map { |e| store_array.push e.id}
        @store_products = StoreProduct.order('id desc')
        @store_products = @store_products.set_store_in(store_array)
        @store_products_count = @store_products.count
        @store_products = @store_products.page(params[:page]).per(_per) if params[:page].present?

        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end