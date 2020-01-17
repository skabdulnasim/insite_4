module Api
  module V2
    class CouponsController < ApplicationController 
      
      before_filter :authenticate_user_with_token!
      
      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/coupons', "List of all coupons. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      
      def index
        @coupons = Coupon.all
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'verify_coupon' action
      api :GET, '/api/v2/verify_coupon', "Verification of coupon code. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :coupon_code,  String, :required => true, :desc => "Coupon code."
      
      def verify_coupon
        begin
          ActiveRecord::Base.transaction do
            @coupon = Coupon.by_code(params[:coupon_code])
            # @coupon = Coupon.find_by_code(params[:coupon_code])
            raise "Coupon code is invalid" unless @coupon.present?
            raise "Coupon code is not active" unless @coupon[0].status=="active"
            @coupon = @coupon.check_coupon_date_validity(Date.today)
            raise "Promo code has been expired" unless @coupon.present?
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end
