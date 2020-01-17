module Api
  module V2
    class ReservationsController < ApplicationController 
      #before_filter :authenticate_user_with_token!,only: [:index,:create]
      
      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/reservations', "List of all reservations. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => false, :desc => "Filter reservations of an unit"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :reservation_date, String, :required => false, :desc => "This parameter can be used to get results this date."
      param :slot_ids, String, :required => false, :desc => "Filter response by slots."      
      param :resource_id, String, :required => false, :desc => "Filter response by resource."      
      param :trash, String, :required => false, :desc => "The value of trash param is 0 or 1."
      param :Customer_id, String, :required => false, :desc => "Id of the customer"
      param :start_date, String, :required => false, :desc => "start date of reservations"
      param :end_date, String, :required => false, :desc => "end date of reservations"

			def index
        _per = params[:count] || 20
        @reservations = Reservation.not_checked_out.order("id desc")
        @reservations = @reservations.by_unit(params[:unit_id]) if params[:unit_id].present?
        @reservations = @reservations.by_customer(params[:Customer_id]) if params[:Customer_id].present?
        @reservations = @reservations.by_resource(params[:resource_id]) if params[:resource_id].present?
        @reservations = @reservations.set_slot_in(params[:slot_ids]) if params[:slot_ids].present?
        @reservations = @reservations.by_date(params[:reservation_date]) if params[:reservation_date].present?
        @reservations = @reservations.by_id(params[:id_filter]) if params[:id_filter].present?
        @reservations = @reservations.not_trash(params[:trash]) if params[:trash].present?
        @reservations = @reservations.by_date_range(params[:start_date].to_date, params[:end_date].to_date) if params[:start_date].present? && params[:end_date].present?

        @count = @reservations.count
        @reservations = @reservations.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception  
      end

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/reservations', "API to create a reservation. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :reservation, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
          ==== Customer Exists ====
            {
              "pax": "4",
              "customer_queue_id": "64",
              "unit_id": "12",
              "source": "direct",
              "user_id": "15",
              "device_id": "YOTTO05",
              "status": "0",
              "customer_mobile" : "8981592166",
              "reservation_details_attributes":[
                {
                "resource_id":"1"
                },
                {
                "resource_id":"2"
                }
              ]
            }

            ==== Customer Not Exists ====
            {
              "own_customer": {
                "name": "Subhra Kanti Ray",
                "customer_unique_id": "ttttt7777",
                "mobile_no": "11111111111",
                "email": "subhrakanti@gmail.com"
              },
              "reservation": {
                "slot_id": "1",
                "start_date": "2017-08-12",
                "end_date": "2017-08-13",
                "pax": "1",
                "unit_id": "12",
                "source": "direct",
                "user_id": "15",
                "device_id": "YOTTO05",
                "status": "0",
                "customer_mobile": "8981592166",
                "reservation_details_attributes":[
                  {
                  "resource_id":"1"
                  },
                  {
                  "resource_id":"2"
                  }
                ]
              }
            }

        EOS
      formats ['json']
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      description <<-EOS
        EOS
      example '
      Success Response (POST Request: http://silvershine.lvh.me:3000/api/v2/reservations?device_id=YOTTO05&email=mantri@silvershines.com)
        {
          "status": "ok",
          "messages": {
              "simple_message": "Reservation successfully created",
              "internal_message": "Reservation successfully created"
          },
          "data": {
              "id": 43,
              "reservation_date": null,
              "own_customer_id": 10,
              "created_at": "2017-10-19T12:43:27+05:30",
              "pax": 4,
              "customer_queue_id": 64,
              "source": "Direct",
              "user_id": "15",
              "device_id": "YOTTO05",
              "start_time": "18-10-2017, 12:00 AM",
              "end_time": "26-10-2017, 12:00 AM",
              "own_customer": {
                  "id": 10,
                  "name": "Subhra kanti ray",
                  "email": "subhra@gmail.com",
                  "mobile_no": "9674442232",
                  "customer_unique_id": "wer890",
                  "addresses": [
                    {
                        "id": 9,
                        "landmark": "Behala",
                        "city": "Kolkata",
                        "state": "West Bengal",
                        "pincode": "712410",
                        "contact_no": "9674442296",
                        "latitude": "444.123",
                        "longitude": "555.123"
                    }
                  ]
              },
              "resource": {
                  "id": 3,
                  "name": "Room 3",
                  "resource_type": "Hotel",
                  "resource_properties": {
                      "": null
                  },
                  "resource_image": "/system/resources/resource_images/000/000/003/original/ball_%28copy%29.jpg?1508082711",
                  "capacity": 4,
                  "price": 2000,
                  "currency": "Rs"
              }
          }
        }
        '

			def create
        ActiveRecord::Base.transaction do
          @reservation = Reservation.new(params[:reservation]) 
          unless @reservation.new_record? and @reservation.save
            @validation_errors = error_messages_for(@reservation)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception        
      end


			def show
        @reservation = Reservation.find(params[:id]) 
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end


      ### => API Documentation (APIPIE) for 'update' action
      api :PUT, '/api/v2/reservations/1', "API to update a reservation. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :reservation, Hash, :required => true, :desc => <<-EOS

      ==== A sample parameter value is given below
       {
          "slot_id": "1",
          "start_date": "2017-08-18",
          "end_date": "2017-08-20",
          "pax": "1",
          "own_customer_id": "2",
          "customer_queue_id": "28",
          "unit_id": "12",
          "source": "direct",
          "user_id": "15",
          "device_id": "YOTTO05",
          "status": "0",
          "customer_mobile" : "8981592166",
          "reservation_details_attributes":[
            {
            "resource_id":"1"
            },
            {
            "resource_id":"2"
            }
          ]
        }

        EOS

        formats ['json']
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      description <<-EOS
        EOS
      example '
      Success Response (PUT Request: http://silvershine.lvh.me:3000/api/v2/reservations/6?device_id=YOTTO05&email=mantri@silvershines.com)

        {
          "status": "ok",
          "messages": {
              "simple_message": "Reservation successfully updated",
              "internal_message": "Reservation successfully updated"
          },
          "id": 6,
          "reservation_date": null,
          "own_customer_id": 2,
          "resource_id": 1,
          "created_at": "2017-10-10T17:17:36+05:30",
          "pax": 1,
          "customer_queue_id": 28,
          "source": "Direct",
          "user_id": "15",
          -"device_id": "YOTTO05",
          "start_time": "18-08-2017, 12:00 AM",
          "end_time": "20-08-2017, 12:00 AM",
          "own_customer": {
              "id": 2,
              "name": "Subhra kanti ray",
              "email": "subhra@gmail.com",
              "mobile_no": "8981592122",
              "customer_unique_id": "jk94",
              "addresses": [
                  {
                      "id": 2,
                      "landmark": "Behala",
                      "city": "Kolkata",
                      "state": "West Bengal",
                      "pincode": "712345",
                      "contact_no": "9007812456",
                      "latitude": "44.12",
                      "longitude": "55.12"
                  }
              ]
          },
          "resource": {
              "id": 1,
              "name": "Room 1",
              "resource_type": "Hotel",
              "resource_properties": {
                  "": null
              }
          }
        }
      '
      def update
        ActiveRecord::Base.transaction do
          @reservation = Reservation.find(params[:id]) 
          @reservation.update_attributes(params[:reservation]) if params[:reservation].present?
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?    
      end

      ### => API Documentation (APIPIE) for 'cancel_reservation' action
      api :PUT, '/api/v2/reservations/cancel_reservation', "API to cancel a reservation. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :trash, String, :required => false, :desc => "In cancel value of trash => 1" 
      param :confirm_reservation_cancel, String, :required => false, :desc => "In cancel value of confirm_reservation_cancel => 1" 
      param :id, String, :required => false, :desc => "Reservation id is required"

      def cancel_reservation
        ActiveRecord::Base.transaction do
          @reservation = Reservation.find(params[:id])
          if params[:confirm_reservation_cancel].present?
            @reservation.update_attributes(:confirm_reservation_cancel => params[:confirm_reservation_cancel], :trash => 1)
          elsif params[:trash].present? 
            _pax = 0
            @reservation.update_attribute(:trash, params[:trash])
            _pax = @reservation.pax + @reservation.customer_queue.pax
            @reservation.customer_queue.update_attributes(:is_reserved => 0, :pax => _pax)
          end    
        end 
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?  
      end 

      ### => API Documentation (APIPIE) for 'swap_reservation' action
      api :PUT, '/api/v2/reservations/swap_reservation', "API to cancel a reservation. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :id, String, :required => true, :desc => "Reservation id is required"
      param :new_resource_id, String, :required => true, :desc => "New resource id which resource you want to reserve"
      param :old_resource_id, String, :required => true, :desc => "Old resource id from where you want to swap"
      param :unit_id, String, :required => true, :desc => "Unit id from where you reserve resorce"
      param :user_id, String, :required => true, :desc => "User id of the login user"
      def swap_reservation
        ActiveRecord::Base.transaction do
          _reservation  = Reservation.find(params[:id])
          _old_resource = Resource.find(params[:old_resource_id])
          _new_resource = Resource.find(params[:new_resource_id])  
          if _reservation.pax > _new_resource.capacity
            @validation_errors = "Pax not match with resource capacity"
          else 
            _reservation.update_attributes(:resource_id => _new_resource.id) 
            @reservation = Reservation.find(params[:id])
          end
          if @reservation.present?
            swap_status   = Reservation.swap_reservation @reservation, _new_resource, _old_resource, params[:device_id], params[:user_id], params[:unit_id]
          end
          
        end 
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?   
      end 

		end	
	end
end