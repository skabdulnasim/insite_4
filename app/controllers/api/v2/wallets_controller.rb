module Api
  module V2
    class WalletsController < ActionController::Base
      #before_filter :set_wallet

      api :POST, '/api/v2/wallets/:identity', "API to credit wallet balance."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :wallet, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "wallet_transactions_attributes":[
                {
                  "amount":100,
                  "purpose":"Return",
                  "payment_type":"credit",
                  "remarks":"Return Related", 
                  "creditmode_type":"WalletCashCreditMode", 
                  "creditmode_attributes":
                  {
                    "amount":100
                  }
                }
              ]
            }
        EOS
      formats ['json']
      def credit
        @wallet = Wallet.search(params[:identity]).first || Customer.by_identification(params[:identity]).first.build_wallet
        @wallet.credit(params[:wallet][:wallet_transactions_attributes])
        render json: @wallet
        #rescue Exception => @error
      end
      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/wallets/:identity', "Customer wallet details."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      def show
        @customer = Customer.by_identification(params[:identity])
        if @customer.present?
          @wallet = Wallet.search(params[:identity])
          if @wallet.present?
            @wallet = @wallet.first
          else
            @wallet = Wallet.new(:customer_id => @customer.first.id, :current_balance => 0, :total_credit => 0, :total_debit => 0 )
            @wallet.save
            @wallet.reload
          end  
        end  
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
      
      private
      def set_wallet
        @wallet = Wallet.search(params[:identity]).first || Customer.by_identification(params[:identity]).first.build_wallet
      end
    end
  end
end