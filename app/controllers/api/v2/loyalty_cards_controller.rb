module Api
  module V2
    class LoyaltyCardsController < ApplicationController 
      before_filter :authenticate_user_with_token!
      
      api :GET, "/api/v2/loyalty_cards/:card_no", "View Loayalty card"
      error :code => 404, :desc => "Not Found", :meta => {:anything => "you can think of"}
      formats ['json']
      def show
        @loyalty_card = LoyaltyCard.find_card(params[:id]).first
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :GET, "/api/v2/loyalty_cards/find_by_mobile_no", "Search loyalty card . (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."  
      param :mobile_no, String, :required =>true, :desc => "mobile no of customer"   
      def find_by_mobile_no
        @customer = APIClient.hl_get_resource('get_customer',"login=#{params[:mobile_no]}")
        raise "#{@customer[:error]}" if @customer[:error].present?
        @loyalty_card = LoyaltyCard.by_customer_id(@customer[:success][:customer][:id]).first
        raise "#{@loyalty_card[:error]}" if @loyalty_card[:error].present?
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end