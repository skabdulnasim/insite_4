module Api
  module V2
    class UnitsController < ApplicationController
      before_filter :authenticate_user_with_token!, only: [:units_sales_persons]

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/units', "Get List of branches(units)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :menu_card_scope, String, :desc => "If this parameter is available, then you will get menu cards of corresponding units.", :required => false, :meta => {:allowed_scopes => ["hungryleopard","inhouse"], :example => "menu_card_scope=hungryleopard"}
      param :active_menu_card, String, :required => false, :desc => "Get all active menu card with its sections", :meta => {:example => "active_menu_card=yes"}
      param :reservation, String, :required => false, :desc => "For reservation relared detail",:meta => {:example => "reservation=yes"}
      param :latitude, String, :desc => "If `latitude` parameter is given then request, then in response branches nearest to that lat-long will be returned.", :required => false, :meta => "`latitude` parameter is dependent on `longitude` parameter"
      param :longitude, String, :desc => "If `longitude` parameter is given then request, then in response branches nearest to that lat-long will be returned.", :required => false, :meta => "`longitude` parameter is dependent on `latitude` parameter"
      param :radius, String, :required => false, :desc => "This parameter represents the radius (in Km.) around a given lat-long. Branches under that radius will be returned in response. By default its value is set to 5"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 10 branches"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 10 branches. If you want to define the number of units per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :unittype_id, String, :required => false, :desc => "Filter by unit type"
      param :delivery_pincode, String, :required => false, :desc => "Filter by delivery address pincode"
      formats ['json']
      description <<-EOS
        EOS
      example '
      Success Response (GET Request: http://dev.selfordering.com/api/v2/units?device_id=YOTTO05)
        {
          "status": "ok",
          "messages": {
            "simple_message": "16 branches loaded.",
            "internal_message": "16 units loaded."
          },
          "data": [
            {
              "id": 5,
              "unit_name": "DEMO OUTLET",
              "address": "swami vivekananda road pai layout",
              "landmark": "Mahadevapura",
              "locality": "Pai Layout,Mahadevapura,Pai Layout,Krishna Reddy Industrial Estate,Dooravani Nagar",
              "pincode": "560016",
              "city": "Bengaluru",
              "state": "Karnataka",
              "country": "India",
              "time_zone": "Kolkata",
              "latitude": 12.9959809,
              "longitude": 77.6676955,
              "phone": "2233445566",
              "unittype_id": 3,
              "url": "/api/v2/units/5",
              "other_details": {
                "options": {
                  "payment_options": [
                    "1",
                    "2",
                    "3"
                  ],
                  "cuisine_type": [
                    "1",
                    "2"
                  ],
                  "atmosphere": [
                    "1",
                    "2"
                  ],
                  "min_order_amount": "600",
                  "free_home_delevery": "Available",
                  "reservation": "Yes",
                  "open_from": "09.00 AM",
                  "open_to": "10:00 PM",
                  "day_closing_time": "0",
                  "resturant_time_slot": "60",
                  "bill_footer_text": "THANK YOU VISIT US AGAIN",
                  "bill_header_text": "DEMO OUTLET\r\nKOLKATA"
                },
                "updated_at": "2015-12-24T02:15:30-06:00"
              }
            },
            {
              "id": 9,
              "unit_name": "Sea Shell 3",
              "address": "Frazer Town, Bengaluru, Karnataka, India",
              "landmark": "Near Cafe Cofee Day.",
              "locality": "Pulikeshi Nagar",
              "pincode": "560034",
              "city": "Bengaluru",
              "state": "Karnataka",
              "country": "India",
              "time_zone": "Kolkata",
              "latitude": 12.9971503,
              "longitude": 77.6142558,
              "phone": "4593434454",
              "unittype_id": 3,
              "url": "/api/v2/units/9"
            }
          ]
        }

      Error Response (GET Request: http://dev.selfordering.com/api/v2/units?device_id=YOTTO05)

        {
          "status": "error",
          "messages": {
            "simple_message": "Sorry!! Could not find any branches",
            "internal_message": "Couldnot find Units",
            "error_code": "",
            "error_url": ""
          },
          "data": {}
        }
      '
      ### => 'index' API

      def index
        _per = params[:count].present? ? params[:count] : 10
        _radius = params[:radius].present? ? params[:radius] : 5
        @units = Unit.non_trashed.order('id')
        @units = @units.by_unittype(params[:unittype_id]) if params[:unittype_id].present?
        @units = @units.set_city(params[:city]) if params[:city].present?
        @units = @units.near([params[:latitude], params[:longitude]], _radius, :units => :km, :order => :distance) if params[:latitude].present? and params[:longitude].present?
        if params[:delivery_pincode].present?
          check_addr = DeliveryAddress.check_address(params[:delivery_pincode])
          if check_addr.present?
            delivery_addresses_ids = check_addr.pluck(:id)
            dv_add_units = DeliveryAddressesUnit.set_delivery_address_id_in(delivery_addresses_ids)
            if dv_add_units.present?
              dv_add_unit_ids = dv_add_units.uniq.pluck(:unit_id)
              @units = @units.set_id_in(dv_add_unit_ids)
            end
          end
        end
        @units = @units.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'show' action
      api :GET, '/api/v2/units/:id', "Fetch details of a branch(unit)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :id, String, :desc => "Branch(Unit) ID", :required => true, :missing_message => lambda { I18n.t("Unit ID is required") }
      param :reservation, String, :required => false, :desc => "For reservation relared detail",:meta => {:example => "reservation=yes"}
      param :resources, String, :desc => "This parameter defines, how many extra resources, associated with this branch(unit) will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :required => false, :meta => {:allowed_resources => ["sections, menu_cards (Dependent on: sections), tables (Dependent on: sections),resources (Dependent on: sections), printers, users, advertisements,bill_destinations,tsp,work_statuses,customer_states,delivery_charges,return_policy,cancelation_policy"], :example => "resources=sections,menu_cards,users,tsp,work_statuses,customer_states,accepted_currencies"}
      formats ['json']
      description <<-EOS
        EOS
      example '
      Success Response (GET Request: http://dev.selfordering.com/api/v2/units/5?resources=printers&device_id=YOTTO05)
        {
          "status": "ok",
          "messages": {
            "simple_message": "Branch found",
            "internal_message": "Unit found with ID 5."
          },
          "data": {
            "id": 5,
            "unit_name": "DEMO OUTLET",
            "address": "swami vivekananda road pai layout",
            "landmark": "Mahadevapura",
            "locality": "Pai Layout,Mahadevapura,Pai Layout,Krishna Reddy Industrial Estate,Dooravani Nagar",
            "pincode": "560016",
            "city": "Bengaluru",
            "state": "Karnataka",
            "country": "India",
            "time_zone": "Kolkata",
            "latitude": 12.9959809,
            "longitude": 77.6676955,
            "phone": "2233445566",
            "unittype_id": 3,
            "unit_type": "Outlet",
            "other_details": {
              "options": {
                "payment_options": [
                  "1",
                  "2",
                  "3"
                ],
                "cuisine_type": [
                  "1",
                  "2"
                ],
                "atmosphere": [
                  "1",
                  "2"
                ],
                "min_order_amount": "600",
                "free_home_delevery": "Available",
                "reservation": "Yes",
                "open_from": "09.00 AM",
                "open_to": "10:00 PM",
                "day_closing_time": "0",
                "resturant_time_slot": "60",
                "bill_footer_text": "THANK YOU VISIT US AGAIN",
                "bill_header_text": "DEMO OUTLET\r\nKOLKATA"
              },
              "updated_at": "2015-12-24T02:15:30-06:00"
            },
            "printers": [
              {
                "id": 18,
                "ip": "192.168.9.150",
                "name": "print 1",
                "assignable_type": "Sort",
                "assignable_id": 3,
                "assignable_name": "sort 3"
              },
              {
                "id": 19,
                "ip": "192.168.9.150",
                "name": "print 1",
                "assignable_type": "Sort",
                "assignable_id": 2,
                "assignable_name": "Sort 2"
              }
            ]
          }
        }

      Error Response (GET Request: http://dev.selfordering.com/api/v2/units/55?resources=printers&device_id=YOTTO05)

        {
          "status": "error",
          "messages": {
            "simple_message": "Sorry!! branch not found",
            "internal_message": "Couldnot find Unit with id=55",
            "error_code": "",
            "error_url": ""
          },
          "data": {}
        }
      '
      ### => 'show' API
      def show
        @today = Date.today
        @unit = Unit.find(params[:id])
        @device_id = params[:device_id]
        @resources = params[:resources].split(',') if params[:resources].present?
        if @resources.include? 'vendor_pjp' and params[:user_id].present?
          _current_date = Date.today.beginning_of_month
          _upto_date = Date.today.end_of_month
          @pjp_date = {}
          (_current_date.._upto_date).each do |t_date|
            arr = Array.new()
            vendors = {}
            user_allocations = UserVendor.by_date(t_date).by_user(params[:user_id])
            user_allocations.each do |ua|
              vendors["id"] = ua.vendor_id
              vendors["name"] = ua.vendor.name
              vendors["phone"] = ua.vendor.phone
              vendors["pan_no"] = ua.vendor.pan_no
              vendors["address"] = ua.vendor.address
              vendors["address_phone_no"] = va.vendor.address_phone_no
              vendors["unit_id"] = ua.vendor.unit_id
              vendors["email"] = ua.vendor.email
              vendors["gst_hash"] = ua.vendor.gst_hash
              vendors["latitude"] = ua.vendor.latitude
              vendors["longitude"] = ua.vendor.longitude
              arr.push vendors
            end  
            @pjp_date[t_date] = arr
          end
        end  
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :GET, '/api/v2/units/get_units/', "Get List of all units and stores."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      def get_units
        @units = Unit.non_trashed.order('id').excluding_ids([1,2])
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end


      def units_sales_persons
        # if @current_user.role.name == "owner"
        #   @units = Unit.non_trashed.order('id')
        # else
        #   @units = Unit.find(@current_user.unit.id)
        # end
        _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
        @units = Unit.set_id_in(_unit_id)
        @roll_arr = Array.new
        sale_person_role = Role.find_by_name("sale_person")
        @roll_arr.push(sale_person_role.id)
        
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end