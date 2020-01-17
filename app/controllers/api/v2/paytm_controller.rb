module Api
  module V2
    class PaytmController < ApplicationController
      include PaytmHelper
      before_filter :get_paytm_keys
      require "net/http"  
      require 'json'
      require 'uri'
      api :GET, '/api/v2/paytm/get_checksum', "Generate checksum"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :order_id, String, :required => true, :desc => "unique order id"
      param :customer_id, String, :required => true, :desc => "unique customer id"
      param :txn_amount, String, :required => true, :desc => "total amount"
      #param :customer_mobile, String, :required => true, :desc => "mobile no of customer"
      #param :customer_email, String, :required => true, :desc => "email of customer"
      def get_checksum
        paramList = Hash.new
        paramList["MID"] = @paytm_keys.mid
        paramList["ORDER_ID"] = params[:order_id]
        paramList["CUST_ID"] = params[:customer_id]
        paramList["INDUSTRY_TYPE_ID"] = @paytm_keys.industry_type_id
        paramList["CHANNEL_ID"] = @paytm_keys.channel_id
        paramList["TXN_AMOUNT"] = params[:txn_amount]
        #paramList["MSISDN"] = params[:customer_mobile]
        #paramList["EMAIL"] = params[:customer_email]
        paramList["WEBSITE"] = @paytm_keys.website
        #paramList["CALLBACK_URL"] = "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=#{params[:order_id]}"  #Provided by Paytm
        paramList["CALLBACK_URL"] = "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=#{params[:order_id]}"  #Provided by Paytm
        @paramList=paramList
        
        @checksum_hash=generate_checksum()
        puts @checksum_hash
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :POST, '/api/v2/paytm/verify_payment', "Varify payment to paytm"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :ORDER_ID, String, :required => true, :desc => "unique order id"
      param :MID, String, :required => true, :desc => "Paytm MID"
      def verify_payment
        paytmparams = Hash.new
        keys = ['MID','ORDER_ID']
        keys.each do |k|
          paytmparams[k] = params[k]
        end
        @paramList = paytmparams
        @checksum_hash=generate_checksum()
        @is_valid_checksum = verify_checksum()
        if @is_valid_checksum == true
          #uri = URI('https://securegw-stage.paytm.in/merchant-status/getTxnStatus')
          uri = URI('https://securegw.paytm.in/merchant-status/getTxnStatus')
          http = Net::HTTP.new(uri.host, uri.port)
          req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
          req.body = {"MID" => params['MID'], "ORDER_ID" => params['ORDER_ID'], "CHECKSUMHASH" => @checksum_hash}.to_json
          http.use_ssl = (uri.scheme == "https")
          res = http.request(req)
          res = JSON.parse(res.body)
          if res["STATUS"] = "TXN_SUCCESS" && res["TXNID"].present?
            @res = res
          else
            @error = res
          end    
        end
      end

      private

      def get_paytm_keys
        #@paytm_keys=Rails.application.config.paytm_keys
        @paytm_keys = PaytmSecurity.first
      end
    end
  end
end
