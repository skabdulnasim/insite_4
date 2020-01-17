module SettlementsHelper
  def create_settlement_apipie_doc
    api :POST, '/settlements', "Create settlement with payment"
    formats ['json', 'jsonp']    
    description "URL : http://dev.selfordering.com/settlements.json?device_id=YOTTO05"
    error :code => 401, :desc => "Unauthorized"
    param :loyalty_card_identity,
          String,
          :required => false,
          :desc => 'If loyalty card serial number provided then loyalty points will be credited to card according to bill amount.'
    param :settlement, 
          String,
          :required => true,
          :desc => 'Settlement information required in JSON format, example given below:
            {
              "status":"paid",
              "bill_id":172,
              "bill_amount":270,
              "tips":0,
              "client_id":1,
              "client_type":"user",
              "split_bill_id":1
              "recorded_at":"2016-04-03 17:16:16"

            }'
    param :payments, 
          String, 
          :required => true,
          :desc => ' 
            To get payment option list check API for rooms and third_party_payments.
            Diferent payment mode JSON given below. Which payment method will be applicable for settlement send that data only (You can always send more than one payment mode).
            
            [
              {
                "payment_mode":"cash",
                "data": {
                  "amount":100,
                  "balance_return":0,
                  "denomination":0,
                  "tendered_amount":100
                  }
              },
              {
                "payment_mode": "card",
                "data": {
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
                "payment_mode": "couponPayment",
                "data": {
                  "no": "GC007",
                  "validity": "2017-11-23",
                  "name": "Festive Gift Coupon",
                  "provider": "HDFC credit card",
                  "denomination":0,
                  "amount": 1000
                  }
              },  
              {
                "payment_mode": "account_payment",
                "data": {
                  "user_id": 1,
                  "amount": 1000
                  }
              },  
              {
                "payment_mode": "room_payment",
                "data": {
                  "room_id": 7,
                  "amount": 1000
                  }
              },
              {
                "payment_mode": "third_party_payment",
                "data": {
                  "third_party_payment_option_id": 2,
                  "amount": 1000
                  }
              },  
              {
                "payment_mode": "loyalty_card_payment",
                "data": {
                  "card_identity": "648HG923",
                  "amount": 1000
                  }
              }                
            ]'
  end

end
