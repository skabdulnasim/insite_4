module Api
  module V2
    class PromotionsController < ApplicationController 
      
      #before_filter :authenticate_user_with_token!
      
      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/promotions', "List of all promotions. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :promo_user, String, :required => false, :dese=> "Filter promotions by staff or customer"
      def index
        @promotions = params[:promo_code].present? ? AlphaPromotion.active.by_code(params[:promo_code]) : AlphaPromotion.active
        @promotions = @promotions.by_promo_user(params[:promo_user]) if params[:promo_user].present?
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
      
      def verify_promo
        begin
          ActiveRecord::Base.transaction do
            @promotions = Unit.find(params[:unit_id]).alpha_promotions.active if params[:unit_id].present?
            @promotions = @promotions.by_code(params[:promo_code]) if params[:promo_code].present?
            raise "Promo code is invalid or inactive" unless @promotions.present?
            # @current_date = Date.today
            @current_date = DateTime.now.utc
            @promotions = @promotions.check_promo_date_validity(@current_date)
            raise "Promo code has been expired" unless @promotions.present?
            @promotion_id = @promotions[0].id
            @promo_count = @promotions[0].count
            @customer_promo = CustomerPromo.find_by_promo_id_and_customer_id(@promotion_id,params[:customer_id]) if params[:customer_id].present?
            if @customer_promo.present?
              @customer_promo_count = @customer_promo.count
              raise "Uses of promo code is over" if @customer_promo_count >= @promo_count
            end
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end
