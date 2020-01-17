module Api
  module V2
    class PaypalsController < ApplicationController
      require "braintree"
      require 'json'

      before_filter :create_gateway

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/paypals/client_token', "Client token for payment."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      ### => 'index' API Defination
      def client_token
        @client_token = @gateway.client_token.generate
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :POST, '/api/v2/paypals/checkout', "Create transaction."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :payment_method_nonce, String, :required => true, :desc => "nonce of paypal"
      param :amount, String, :required => true, :desc => "amount that you want to paid"
      param :currency, String, :required => true, :desc => "currency of country"
      param :order_id, String, :required => true, :desc => "order_id must be unique value"
      param :first_name, String, :required => false, :desc => "first_name of paypal account holder"
      param :last_name, String, :required => false, :desc => "last_name of paypal account holder"
      param :company, String, :required => false, :desc => "company of paypal account holder"
      param :street_address, String, :required => false, :desc => "street_address of paypal account holder"
      param :extended_address, String, :required => false, :desc => "extended_address of paypal account holder"
      param :locality, String, :required => false, :desc => "locality of paypal account holder"
      param :region, String, :required => false, :desc => "region of paypal account holder"
      param :postal_code, String, :required => false, :desc => "postal_code of paypal account holder"
      param :country_code, String, :required => false, :desc => "country_code of paypal account holder"

      def checkout
        @result = @gateway.transaction.sale(
          :amount => params[:amount],
          :merchant_account_id => params[:currency],
          :payment_method_nonce => params[:payment_method_nonce],
          :order_id => params[:order_id],
          
          :shipping => {
            :first_name => params[:first_name],
            :last_name => params[:last_name],
            :company => params[:company],
            :street_address => params[:street_address],
            :extended_address => params[:extended_address],
            :locality => params[:locality],
            :region => params[:region],
            :postal_code => params[:postal_code],
            :country_code_alpha2 => params[:country_code]
          },
          :options => {
            :submit_for_settlement => true
          }
        )
        puts @result.inspect
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

      def create_gateway
        @gateway = Braintree::Gateway.new(
          :access_token => "access_token$sandbox$f4jy4jmqfxrv38rx$c0cd1c5b34be55156b6215ce3da299a3"
        )
      end

    end
  end
end
