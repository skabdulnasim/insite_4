module Api
	module V2
		class CustomerQueuesController < ApplicationController
      require "braintree"

			### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/customer_queues', "API to list of all customer in queue"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :trash, String, :required => false, :desc => "The value of trash param is 0 or 1."
			param :is_reserved, String, :required => false, :desc => "The value of is_reserved param is 0 or 1."
      param :unit_id, String, :required => false, :desc => "The value of unit_id is current user unit id"
      param :customer_id, String, :required => false, :desc => "Valu of the login customer"
			param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :resources, String, :desc => "This parameter defines, how many extra resources, associated with bill will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :required => false, :meta => {:allowed_resources => ["customer","unit"], :example => "resources=customer,unit "}
      param :slot_id, String, :required => false, :desc => "The id of the slot."
      param :date, String, :required => false, :desc => "date is required for filter"
      
      def index
        _per = params[:count] || 20
        @customer_queues = CustomerQueue.order("id desc")
        @customer_queues = @customer_queues.set_trash(params[:trash]) if params[:trash].present?
        @customer_queues = @customer_queues.set_is_reserved(params[:is_reserved]) if params[:is_reserved].present?
        @customer_queues = @customer_queues.set_unit_id(params[:unit_id]) if params[:unit_id].present?
        @customer_queues = @customer_queues.set_customer_id(params[:customer_id]) if params[:customer_id].present?
        @customer_queues = @customer_queues.by_slot(params[:slot_id]) if params[:slot_id].present?
        @customer_queues = @customer_queues.by_date(params[:date]) if params[:date].present?
        @count           = @customer_queues.count
        @customer_queues = @customer_queues.page(params[:page]).per(_per) if params[:page].present?
        @resources       = params[:resources].present? ? params[:resources].split(',') : ["unit","customer"]
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception 
      end

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/customer_queues', "API to create a customerqueue. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :customer_queue, Hash, :required => true, :desc => <<-EOS
 
      ==== A sample parameter is given below  ====
      ==== Existing customer ====
 
      {
        "customer_queue": {
          "pax": "6",
          "total_pax": "6",
          "from_date": "2016-04-02 11:30",
          "to_date": "2016-04-02 12:30",
          "customer_id": "10",
          "unit_id": "7",
          "slot_id": "2",
          "customer_unique_id": "wer1234",
          "customer_queue_state_id":"1"
        }
      }
 
    Success Response (POST Request: http://silvershine.lvh.me:3000/api/v2/customer_queues?device_id=YOTTO05&email=mantri@silvershines.com)
 
      {
        "status": "ok",
        "messages": {
            "simple_message": "Customer queue created",
            "internal_message": "Customer queue created"
        },
        "data": {
            "id": 10,
            "name": "Subhra kanti ray",
            "email": "subhra@gmail.com",
            "mobile_no": "9674442232",
            "customer_unique_id": "wer890",
            "address": {
              "id": 9,
              "landmark": "Behala",
              "city": "Kolkata",
              "state": "West Bengal",
              "pincode": "712410",
              "contact_no": "9674442296",
              "latitude": "444.123",
              "longitude": "555.123"
            },
            "customer_queues": {
              "id": 63,
              "pax": 6,
              "trash": 0,
              "is_reserved": 0,
              "total_pax": "6",
              "from_date": "04-10-2017, 11:30 AM",
              "to_date": "07-10-2017, 12:30 PM",
              "unit_id": "7",
              "slot_id": "2",
              "customer_id": "1"
            },
            "customer_queue_state":{
              "id":1,
              "name":"Initial",
              "color_code":"#ccccc"
            }
        }
      }
			
      EOS
	
			def create
				ActiveRecord::Base.transaction do
          if params[:customer_queue].present?
            @customer_queue = CustomerQueue.new(params[:customer_queue])
            _preauth = @customer_queue.unit.unit_detail.options[:preauth]
            pax = @customer_queue.pax
            unless @customer_queue.pax.even?
              pax = @customer_queue.pax + 1
            end 
            @preauth = _preauth.to_f * pax 
            @customer_queue[:preauth_value] = @preauth
            @customer_queue.save
            @customer = Customer.find(params[:customer_queue][:customer_id])
          end       
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception  
			end

			### => API Documentation (APIPIE) for 'update' action
      api :PUT, '/api/v2/customer_queues/:id', "API to update a customerqueue. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :trash, String, :required => false, :desc => "trash value mustbe 1 to cancel queue"
			def update
        ActiveRecord::Base.transaction do
        	@customer_queue = CustomerQueue.find(params[:id]) 
        	@customer_queue.update_attributes(:trash => params[:trash], :customer_queue_state_id => 4)
          # if @customer_queue.preauths.present?
          #   #Paypal cancel function goes here
          #   puts "Paypal cancel function goes here"
          #   # @gateway = Braintree::Gateway.new(
          #   #   :access_token => "access_token$sandbox$f4jy4jmqfxrv38rx$c0cd1c5b34be55156b6215ce3da299a3"
          #   # )
          #   result = Braintree::Transaction.refund("awm6p7qt")
          #   puts result.inspect
          # end        
        	@customer = Customer.find(@customer_queue.customer_id)
        end  
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception 
      end

      api :GET, '/api/v2/customer_queues/:id', "API to get a customerqueue. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      def show
        @customer_queues = CustomerQueue.by_id(params[:id])
        @resources       = params[:resources].present? ? params[:resources].split(',') : ["unit","customer"]
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

		end
	end	
end	