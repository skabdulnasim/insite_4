module Api
  module V2
    class MoneyRefundsController < ApplicationController

    	### => API Documentation (APIPIE) for 'bill_on_hold' action
      api :POST, '/api/v2/money_refunds/', "API for requesting refund after cancel order or return item. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :money_refund, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "order_id": "2",
              "paymentmode": "cash",
              "refund_amount": "789",
              "account_no": "00000000000000",
              "ifsc_code":"abcd0000"
            }
        EOS
    	def create
    		@money_refund = MoneyRefund.new(params[:money_refund])
    		_order = Order.find(params[:money_refund][:order_id])
    		@money_refund.customer_id = _order.customer_id
    		
    		@money_refund.save
			end

    end
  end
end