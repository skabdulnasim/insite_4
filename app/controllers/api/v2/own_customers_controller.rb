module Api
  module V2
    class OwnCustomersController < ApplicationController

      ### => API Documentation (APIPIE) for 'find_by_identifications' action
      api :GET, 'api/v2/own_customers/find_by_identifications', "(Authorization header required for authentication)"
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)." 
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :identification, String, :required => true, :desc => "(Example, :identification => email/mobile_no)."
    	
      def find_by_identifications
    		@own_customer = OwnCustomer.by_login(params[:identification]).last
    		raise "#{@own_customer[:error]}" if @own_customer[:error].present?
    		rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
    	end

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/own_customers', "API to generate a customer. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :own_customer, Hash, :required => true, :desc => <<-EOS
          ==== A sample parameter value is given below ====
          {
            "own_customer": {
              "name": "Subhra kanti ray",
              "customer_unique_id":"wer890",
              "mobile_no": "9674442232",
              "email": "subhra@gmail.com",
              "own_customer_addresses_attributes":  [
                  {
                    "contact_no": "9674442296",
                    "pincode": "712410",
                    "landmark": "Behala",
                    "city": "Kolkata",
                    "state": "West Bengal",
                    "latitude": "444.123",
                    "longitude": "555.123"
                  }
                ],
              "customer_queues_attributes":  [
                 {
                   "pax": "6",
                   "from_date": "01-10-2017",
                   "to_date": "05-10-2017",
                   "total_pax": "6"
                 }
                ]
            }
        }

      Success Response (POST Request: http://silvershine.lvh.me:3000/api/v2/own_customers?device_id=YOTTO05&email=mantri@silvershines.com)

          {
            "status": "ok",
            "messages": {
                "simple_message": "Customer created",
                "internal_message": "Customer created"
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
                    "id": 58,
                    "pax": 6,
                    "total_pax": "6",
                    "from_date": "04-10-2017, 12:00 AM",
                    "to_date": "07-10-2017, 12:00 AM"
                }
            }
          }

          EOS

      def create
        ActiveRecord::Base.transaction do
          @own_customer = OwnCustomer.find_by_mobile_no(params[:own_customer][:mobile_no]) if params[:own_customer][:mobile_no].present?
          unless @own_customer.present?
            @own_customer = OwnCustomer.new(params[:own_customer]) 
            @own_customer.save
          end
        end 
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception            
      end 

      ### => API Documentation (APIPIE) for 'update' action
      api :POST, '/api/v2/own_customers/1', "API to update a customer. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :own_customer, Hash, :required => true, :desc =>  <<-EOS
          ==== A sample parameter value is given below ====
          {
            "own_customer": {
              "name": "Bipra kanti ray",
              "customer_unique_id": "utr567",
              "mobile_no": "90078123634",
              "email": "bipra@gmail.com",
              "own_customer_addresses_attributes":  [
                {
                  "contact_no": "90078123744",
                  "pincode": "712454",
                  "landmark": "Behala",
                  "city": "Kolkata",
                  "state": "West Bengal",
                  "latitude": "4455.123",
                  "longitude": "5544.123"
                }
              ]
            }
          }

      Success Response (PUT Request: http://silvershine.lvh.me:3000/api/v2/own_customers/75?device_id=YOTTO05&email=mantri@silvershines.com)

        {
          "status": "ok",
          "messages": {
              "simple_message": "translation missing: en.success_own_customer_updated",
              "internal_message": "Customer updated"
          },
          "data": {
            "id": 75,
            "name": "Bipra kanti ray",
            "email": "bipra@gmail.com",
            "mobile_no": "90078123634",
            "customer_unique_id": "utr567",
            "addresses": [
              {
                "id": 62,
                "landmark": "sahapur",
                "city": "tarakeswar",
                "state": "West Bengal",
                "pincode": "712410",
                "contact_no": "90078123743",
                "latitude": "444.123",
                "longitude": "555.123"
              },
              {
                "id": 63,
                "landmark": "Behala",
                "city": "Kolkata",
                "state": "West Bengal",
                "pincode": "712454",
                "contact_no": "90078123744",
                "latitude": "4455.123",
                "longitude": "5544.123"
              }
            ]
          }
        }

        EOS
          
      def update
        ActiveRecord::Base.transaction do    
          @own_customer = OwnCustomer.find(params[:id])
          @own_customer.update_attributes(params[:own_customer])  
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception  
      end
    end	
  end  	
end