module Api
  module V2
    class LoyaltyPurchasesController < ApplicationController 
      before_filter :authenticate_user_with_token!
      load_and_authorize_resource
      before_filter :day_to_date



      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/loylaty_purchases', "Loyalty purchases (Enrollment/Recharge)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."      
      
      param :loyalty_purchase, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
        {
          "card_identity":"b26866f5", /* crad_no / card_serail
          "purchase_cost":"100", /* Amount */
          "purchase_type":"recharge", /* recharge/enrollment */
          "loyalty_credit_transaction_attributes":{  
            "validity":"45", /* Days */
            "refundable":"0" /* Boolean true/false */
          }
        }
      EOS
      formats ['json']

      def create
        ActiveRecord::Base.transaction do
          @loyalty_purchase = LoyaltyPurchase.new(params[:loyalty_purchase])
          if @loyalty_purchase.save
            @loyalty_purchase.reload
          else
            @validation_errors = error_messages_for(@loyalty_purchase)
          end
        end
        #@resources = params[:resources].present? ? params[:resources].split(',') : []
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception 
      end

      private

      def day_to_date
        validity_days = params[:loyalty_purchase][:loyalty_credit_transaction_attributes][:validity].to_i
        params[:loyalty_purchase][:loyalty_credit_transaction_attributes][:validity] = validity_days.days.from_now.end_of_day + current_user.unit.unit_detail.options[:day_closing_time].to_i.hours
      end
    end
  end
end