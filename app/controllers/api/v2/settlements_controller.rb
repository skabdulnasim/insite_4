module Api
  module V2
    class SettlementsController < ApplicationController 
      
      before_filter :authenticate_user_with_token!
      load_and_authorize_resource

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/settlements', "API for bill settlement. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :settlement, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
             {
                "bill_id":"2225",
                "tips":"0",
                "client_id":"4",
                "client_type":"user",
                "device_id":"YOTTO05",
                "recorded_at":"2016-04-02 11:50",
                "loyalty_credit_transaction_attributes":{
                   "card_identity":"njnu1n2"
                },
                "payments_attributes":[
                   {
                      "paymentmode_type":"Cash",
                      "paymentmode_attributes":{
                         "tendered_amount":"1202",
                         "amount":"1202",
                         "balance_return":"0",
                         "cash_descriptions_attributes": [{
                            "denomination_id":"6",
                            "count":"2"
                          }],
                          "transaction_currency_details_attributes":[{
                            "accepted_currency_id" : "1",
                            "currency_id" : "119",
                            "amount": 3
                          }]
                      }
                   },
                   {
                      "paymentmode_type":"Card",
                      "paymentmode_attributes":{
                        "no": 547474,
                        "valid_upto": "2014-11-23",
                        "card_type": "debit",
                        "bank": "sbi",
                        "cvv": 123,
                        "merchandiser": "visa",
                        "name_on_card": "avishek",
                        "amount": 1000                        
                      }
                   },
                   {
                      "paymentmode_type":"CouponPayment",
                      "paymentmode_attributes":{
                        "no": "GC007",
                        "validity": "2017-11-23",
                        "name": "Festive Gift Coupon",
                        "provider": "HDFC credit card",
                        "denomination":0,
                        "amount": 1000                       
                      }
                   },                 
                   {
                      "paymentmode_type":"AccountPayment",
                      "paymentmode_attributes":{
                        "user_id": 1,
                        "amount": 1000                  
                      }
                   },
                   {
                      "paymentmode_type":"RoomPayment",
                      "paymentmode_attributes":{
                        "room_id": 7,
                        "amount": 1000               
                      }
                   },                 
                   {
                      "paymentmode_type":"ThirdPartyPayment",
                      "paymentmode_attributes":{
                        "third_party_payment_option_id": 2,
                        "amount": 1000           
                      }
                   },  
                   {
                      "paymentmode_type":"LoyaltyCardPayment",
                      "paymentmode_attributes":{
                        "card_identity": "648HG923",
                        "amount": 1000       
                      }
                   },
                   {
                      "paymentmode_type":"PaypalPayment",
                      "paymentmode_attributes":{
                         "amount":"600",
                         "transaction_id":"40",
                         "recorded_at":"2016-04-02 11:50"
                      }
                   },
                   {
                      "paymentmode_type": "wallet_payment",
                      "paymentmode_attributes": {
                        "wallet_name": "Urbanpiper",
                        "customer_phone": "8759932239",
                        "card_number": "1001001000",
                        "amount": "258"
                      }
                    },
                    {
                      "paymentmode_type": "CustomerWalletPayment",
                      "paymentmode_attributes": {
                        "wallet_id": "1",
                        "amount": "258"
                      }
                    },
                    {
                      "paymentmode_type": "FinalcialAccountPayment",
                      "paymentmode_attributes": {
                        "account_no": "1109987",
                        "customer_id": "2",
                        "finalcial_account_id": "1",
                        "amount": "258"
                      }
                    },
                    {
                      "paymentmode_type": "PaytmPayment",
                      "paymentmode_attributes": {
                        "BANKNAME": "WALLET",
                        "BANKTXNID": "5117085",
                        "GATEWAYNAME": "WALLET",
                        "MID": "OTCFOO25397775981659"
                        "ORDERID": "OTC011009",
                        "PAYMENTMODE": "PPI",
                        "REFUNDAMT": "0.00",
                        "RESPCODE": "01",
                        "RESPMSG": "Txn Success",
                        "STATUS": "TXN_SUCESS",
                        "TXNAMOUNT": "4.00",
                        "TXNDATE": "2018-07-05 17:50:55.0",
                        "TXNID": "20180705111212800110168596500019635",
                        "TXNTYPE": "SALE",
                        "amount": "4.00"
                      }
                    }                                                                                
                ]
             }
          ==== A sample parameter value is given below for split bill settlemnt   
            {
              "bill_id": "36114",
              "client_id": "12",
              "client_type": "User",
              "tips": "0",
              "recorded_at": "2016-04-02 11:50",
              "device_id": "YOTTO05",
              "split_settlements_attributes": [
                {
                  "bill_split_id": "37",
                  "payments_attributes": [
                    {
                      "paymentmode_type": "ThirdPartyPayment",
                      "paymentmode_attributes": {
                        "third_party_payment_option_id": "3",
                        "amount": "200"
                      }
                    }
                  ]
                }
              ]
            }
            
        EOS
      formats ['json']  
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      description <<-EOS
        EOS
      example '
      Success Response (POST Request: http://dev.selfordering.com/api/v2/settlements?device_id=YOTTO05)
        {
          "status": "ok",
          "messages": {
            "simple_message": "Bill settled successfully",
            "internal_message": "Bill settled successfully"
          },
          "data": {
            "id": 1690,
            "bill_id": 2225,
            "bill_amount": 1202,
            "status": "paid",
            "client_id": 4,
            "client_type": "User",
            "client_name": "Shyam Raha",
            "payments": [
              {
                "id": 1514,
                "paymentmode_id": 1303,
                "paymentmode_type": "Cash",
                "created_at": "2016-03-17T17:52:55+05:30",
                "updated_at": "2016-03-17T17:52:55+05:30",
                "paid_amount": 1202,
                "paymentmode_details": ""
              }
            ]
          }
        }

      Error Response (POST Request: http://dev.selfordering.com/api/v2/settlements?device_id=YOTTO05)
        {
          "status": "error",
          "messages": {
            "simple_message": "Something went wrong, try after sometime",
            "internal_message": "Something went wrong, try after sometime."
          },
          "data": {}
        }
      '
      ### => 'create' API                
      def create
        ActiveRecord::Base.transaction do
          @settlement = Settlement.find_by_bill_id(params[:settlement][:bill_id])
          if @settlement.present? && @settlement.split_settlements.present?
            if params[:settlement_type].present?
              if @settlement.update_attributes(params[:settlement])
                @settlement.reload
              else
                @validation_errors = error_messages_for(@settlement)
              end
            else
              if params[:settlement][:split_settlements_attributes][0][:bill_split_id].present?
                if @settlement.update_attributes(params[:settlement])
                  @settlement.reload
                else
                  @validation_errors = error_messages_for(@settlement)
                end
              else
                _splite_bill = BillSplit.by_bill(params[:settlement][:bill_id])
                _splite_bill = _splite_bill.first
                if @settlement.update_attributes(boh_settlements_params(_splite_bill.id))
                  @settlement.reload
                else
                  @validation_errors = error_messages_for(@settlement)
                end
              end
            end  
          else
            @settlement = Settlement.new(params[:settlement])
            if @settlement.save
              @settlement.reload
            else
              @validation_errors = error_messages_for(@settlement)
            end
          end
        end
        @resources = params[:resources].present? ? params[:resources].split(',') : []
        rescue Exception => @error
        #@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception        
      end

      private

      def boh_settlements_params(bill_split_id)
        {
          "bill_id"       => params[:settlement][:bill_id],
          "client_id"     => params[:settlement][:client_id],
          "client_type"   => params[:settlement][:client_type],
          "tips"          => params[:settlement][:tips],
          "recorded_at"   => params[:settlement][:recorded_at],
          "device_id"     => params[:settlement][:device_id],
          "split_settlements_attributes"     => [
            {
              "bill_split_id"             => bill_split_id,
              "payments_attributes"       => params[:settlement][:split_settlements_attributes][0][:payments_attributes]
            }
          ]
        }
      end

    end
  end
end
