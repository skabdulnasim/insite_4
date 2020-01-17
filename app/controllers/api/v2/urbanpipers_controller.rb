module Api
  module V2
    class UrbanpipersController < ApplicationController
      before_filter :authenticate_user_with_token!
      require 'rest-client'
      require 'json'

      ### => API Documentation (APIPIE) for 'customer_register' action
      api :POST, '/api/v2/urbanpipers/customer_register', "Customer registration in Urbanpiper (Authorization header required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :amount, String, :desc => "Any amount​ ​to​ ​be​ ​preloaded​ into​ the​ ​user’s​ ​prepaid balance", :required => false
      param :customer_phone, String, :desc => "The user's phone number along with the ISD country code.", :required => true
      param :customer_name, String, :desc => "Name of the customer.", :required => false
      param :card_number, String, :desc => "To be passed when a plastic card is being allotted to the customer.", :required => false
      param :pin, String, :desc => "The secret pin printed on each plastic card.", :required => false
      param :extra_mc_id, String, :desc => "A unique id to identify the POS machine from which the request was made.", :required => false
      param :extra_op_uname, String, :desc => "A unique username to identify the operator who issued the command to make the request.", :required => false

      formats ['json']
      ### => 'customer_register' API Defination

      def customer_register
        url = 'https://api.urbanpiper.com/api/v2/card/'
        headers = {params: urbanpiper_customer_create_params, Authorization: 'apikey biz_adm_pVdvlRCTNIsVJBCWPaQCRz:ba449add1b685583f9e84e4e37ebc6c804abe0a9'}
        @response = RestClient::Request.execute(method: :post, url: url, headers: headers)
        if JSON.parse(@response)["success"] == false
          @error = @response
        end

      end

      ### => API Documentation (APIPIE) for 'customer_search' action
      api :GET, '/api/v2/urbanpipers/customer_search', "Search customer in Urbanpiper (Authorization header required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :customer_phone, String, :desc => "The phone number of the customer.", :required => false
      param :card_number, String, :desc => "The card number associated with the customer.", :required => false

      formats ['json']
      ### => 'customer_search' API Defination

      def customer_search
        if params[:customer_phone].present?
          headers = {params: {format: params[:format], customer_phone: params[:customer_phone]},Authorization: 'apikey biz_adm_pVdvlRCTNIsVJBCWPaQCRz:ba449add1b685583f9e84e4e37ebc6c804abe0a9'}
        elsif params[:card_number].present?
          headers = {params: {format: params[:format], card_number: params[:card_number]},Authorization: 'apikey biz_adm_pVdvlRCTNIsVJBCWPaQCRz:ba449add1b685583f9e84e4e37ebc6c804abe0a9'}
        end
        url = 'https://api.urbanpiper.com/api/v1/user/profile/'
        @response = RestClient::Request.execute(method: :get, url: url, headers: headers)
        
        rescue RestClient::ExceptionWithResponse => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'customer_profile_update' action
      api :PUT, '/api/v2/urbanpipers/customer_profile_update/:customer_phone', "Update customer profile in Urbanpiper (Authorization header required for authentication)."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :customer_phone, String, :required => true, :desc => "Phone number of the customer."
      param :user_data, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "first_name": "Rohit",
              "last_name":  "Sharma",
              "birthday":   452690069000,
              "anniversary":  457390069000,
              "gender": "male",
              "current_city": "pune",
              "address":  "#214, 4th cross 17th main, kothrud"
            }
        
        EOS
      formats ['json']
      ### => 'customer_profile_update' API

      def customer_profile_update
        customer_phone = params[:customer_phone]
        initheader = { 'Content-Type' => 'application/json',Authorization: 'apikey biz_adm_pVdvlRCTNIsVJBCWPaQCRz:ba449add1b685583f9e84e4e37ebc6c804abe0a9'}
        url = "https://api.urbanpiper.com/api/v1/user/profile/?customer_phone=#{customer_phone}"
        payload = urbanpiper_customer_update_params.to_json
        @response = RestClient.put(url, payload, initheader)
        # @response = RestClient::Request.execute(method: :put, url: url, headers: initheader, payload: payload)
        
        rescue RestClient::ExceptionWithResponse => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception

      end

      ### => API Documentation (APIPIE) for 'wallet_transaction' action
      api :POST, '/api/v2/urbanpipers/wallet_transaction', "Wallet transaction in Urbanpiper (Authorization header required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :amount, String, :desc => "Any amount​ ​to​ ​be​ ​preloaded​ into​ the​ ​user’s​ ​prepaid balance", :required => false
      param :customer_phone, String, :desc => "The user's phone number along with the ISD country code.", :required => true
      # param :card_number, String, :desc => "To be passed when a plastic card is being allotted to the customer (should not be passed when customer_phone is being used).", :required => false
      param :pin, String, :desc => "This is the OTP required to validate the transaction (If customer_phone is being used).​", :required => false
      param :bill_id, String, :desc => "The bill id of the transaction generated by the POS app.", :required => false
      param :rc, String, :desc => "A flag indicating whether this purchase transaction should be treated as a reward cashback.", :required => false
      param :extra_mc_id, String, :desc => "A unique id to identify the POS machine from which the request was made.", :required => false
      param :extra_op_uname, String, :desc => "A unique username to identify the operator who issued the command to make the request.", :required => false

      formats ['json']
      ### => 'wallet_transaction' API Defination

      def wallet_transaction
        url = "https://api.urbanpiper.com/api/v2/card/balance/"
        header = {params:urbanpiper_wallet_transaction_params,Authorization: 'apikey biz_adm_pVdvlRCTNIsVJBCWPaQCRz:ba449add1b685583f9e84e4e37ebc6c804abe0a9'}
        @response = RestClient::Request.execute(method: :post, url: url, headers: header)

        if JSON.parse(@response)["success"] == false
          @error = @response
        end

      end

      ### => API Documentation (APIPIE) for 'processing_purchase' action
      api :POST, '/api/v2/urbanpipers/processing_purchase', "Processing purchase for reward points / cashback in Urbanpiper (Authorization header required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :amount, String, :desc => "The amount value associated with the purchase or return transaction.", :required => false
      param :customer_phone, String, :desc => "The user's phone number along with the ISD country code.", :required => true
      # param :card_number, String, :desc => "To be passed when a plastic card is being allotted to the customer (should not be passed when customer_phone is being used).", :required => false
      param :bill_id, String, :desc => "The bill id of the transaction generated by the POS app.", :required => false
      param :discount, String, :desc => "Any discount value associated with this bill.", :required => false
      param :extra_mc_id, String, :desc => "A unique id to identify the POS machine from which the request was made.", :required => false
      param :extra_op_uname, String, :desc => "A unique username to identify the operator who issued the command to make the request.", :required => false
      param :bill_details, Hash, :required => false, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "sku_data": [{
                "sku_code": "122444",
                "sku_desc": "Description A",
                "qty": 12,
                "line_total": 100,
                "discount": 10,
                "discount_type": "manual",
                "extra": {
                  "key1": "value1",
                  "key2": "value2"
                }
              }, {
                "sku_code": "45541A",
                "sku_desc": "Description B",
                "qty": 1,
                "line_total": 10,
                "discount": 10,
                "discount_type": "manual",
                "extra": {
                  "key1": "value1",
                  "key2": "value2"
                }
              }]
            }
         
        EOS
      formats ['json']
      ### => 'processing_purchase' API Defination

      def processing_purchase
        url = "https://api.urbanpiper.com/api/v2/purchase/"
        headers = {params:urbanpiper_processing_purchase_params, Authorization: 'apikey biz_adm_pVdvlRCTNIsVJBCWPaQCRz:ba449add1b685583f9e84e4e37ebc6c804abe0a9'}
        # @response = RestClient::Request.execute(method: :post, url: url, headers: headers)
        payload = params[:bill_details].to_json
        @response = RestClient.post(url, payload, headers)

        if JSON.parse(@response)["success"] == false
          @error = @response
        end
     
      end

      ### => API Documentation (APIPIE) for 'reward_redemption' action
      api :GET, '/api/v2/urbanpipers/reward_redemption', "This provides support for checking and processing reward redemption codes. (Authorization header required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :redemption_code, String, :required => true, :desc => "The redemption​ code to be validated."
      param :markused, String, :required => false, :desc => "This is a boolean​​ flag to indicate whether​ the redemption​ code should​ be marked​ as used."
      param :extra_mc_id, String, :desc => "A unique id to identify the POS machine from which the request was made.", :required => false
      param :extra_op_uname, String, :desc => "A unique username to identify the operator who issued the command to make the request.", :required => false
      param :extra_amount, String, :desc => "The amount of the bill against which this reward is being claimed.", :required => false

      formats ['json']
      ### => 'reward_redemption' API Defination

      def reward_redemption
        redemption_code = params[:redemption_code]
        url = "https://api.urbanpiper.com/api/v1/redeem/#{redemption_code}?format=json"
        headers = {params: urbanpiper_reward_redemption_params, Authorization: 'apikey biz_adm_pVdvlRCTNIsVJBCWPaQCRz:ba449add1b685583f9e84e4e37ebc6c804abe0a9'}
        @response = RestClient::Request.execute(method: :get, url: url, headers: headers)
        
        rescue RestClient::ExceptionWithResponse => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

      def urbanpiper_customer_create_params
        {
          "amount"              => params[:amount],
          "customer_phone"      => params[:customer_phone],
          "customer_name"       => params[:customer_name],
          # "card_number"         => params[:card_number],
          # "pin"                 => params[:pin],
          "extra_mc_id"         => params[:extra_mc_id],
          "extra_op_uname"      => params[:extra_op_uname]
        }
      end

      def urbanpiper_customer_update_params
        {
          "user_data" =>
            {
              "first_name"      =>   params[:user_data][:first_name],
              "last_name"       =>   params[:user_data][:last_name],
              "birthday"        =>   params[:user_data][:birthday],
              "anniversary"     =>   params[:user_data][:anniversary],
              "gender"          =>   params[:user_data][:gender],
              "current_city"    =>   params[:user_data][:current_city],
              "address"         =>   params[:user_data][:address]
            }
        }
      end

      def urbanpiper_wallet_transaction_params
        {
          "amount"              => params[:amount],
          "customer_phone"      => params[:customer_phone],
          "card_number"         => params[:card_number],
          "pin"                 => params[:pin],
          "bill_id"             => params[:bill_id],
          "rc"                  => params[:rc],
          "extra_mc_id"         => params[:extra_mc_id],
          "extra_op_uname"      => params[:extra_op_uname]
        }
      end

      def urbanpiper_processing_purchase_params
        {
          "format"              => params[:format],
          "amount"              => params[:amount],
          "customer_phone"      => params[:customer_phone]
        }
      end

      def urbanpiper_reward_redemption_params
        {
          "markused"              => params[:markused],
          "extra_mc_id"           => params[:extra_mc_id],
          "extra_op_uname"        => params[:extra_op_uname],
          "extra_amount"          => params[:extra_amount]
        }
      end

    end
  end
end