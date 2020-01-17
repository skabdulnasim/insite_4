module Api
  module V2
    class BoutiqueCapillariesController < ApplicationController
    	require 'rest-client'
      require 'json'
    	api :GET, '/api/v2/boutique_capillaries/customer_search', "Search customer in BoutiqueCpaillaries (Authorization header required)."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :mobile, String, :desc => "The phone number of the customer.", :required => false

      formats ['json']
      ### => 'customer_search' API Defination

      def customer_search
        if params[:mobile].present?
          headers = {Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
        end
        url = "https://api.capillary.co.in/v1.1/customer/get?format=json&mobile=#{params[:mobile]}"
        @response = RestClient::Request.execute(method: :get, url: url, headers: headers)
        if JSON.parse(@response)["response"]["status"]["success_count"] == '0'
          @error = @response
        end
        #rescue RestClient::ExceptionWithResponse => @error
        #@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :POST, '/api/v2/boutique_capillaries/customer_add', "Add customer in BoutiqueCpaillaries (Authorization header required)."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :root, Hash, :required => true, :desc => <<-EOS
      ==== A sample parameter value is given below
        {
          "customer": {
            "mobile": "8759932239",
            "email":"abcdef@gmail.com", 
            "firstname": "Arpita", 
            "lastname": "De",
            "registered_on": "2017-01-02 11:11:11", 
            "custome_fields": {
              "field": [
                {
                "name": "address",
                "value": "Dubai"
                },
                {
                "name": "anniversary",
                "value": "10-04-2015"
                },
                {
                "name": "birthday",
                "value": "10-04-1987"
                },
                {
                "name": "nationality",
                "value": "Dubai"
                },
                {
                "name": "gender",
                "value": "Male"
                }
              ]
            }
          }
        }  
          
      EOS

      formats ['json']
      def customer_add
        hash = {}
        initheader = { 'Content-Type' => 'application/json',Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
        url = "http://api.capillary.co.in/v1.1/customer/add?format=json"
        hash["root"] = params[:root]
        payload = hash.to_json
        @response = RestClient::Request.execute(method: :post, url: url, headers:initheader , payload:payload)
        # @response = RestClient.post(url, payload, initheader)
      end

      api :POST, '/api/v2/boutique_capillaries/customer_profile_update', "Update customer in BoutiqueCpaillaries (Authorization header required)."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :root, Hash, :required => true, :desc => <<-EOS
      ==== A sample parameter value is given below
        {
          "customer": {
            "mobile": "8759932239",
            "email":"abcdef@gmail.com", 
            "firstname": "Arpita", 
            "lastname": "De",
            "registered_on": "2017-01-02 11:11:11", 
            "custome_fields": {
              "field": [
                {
                "name": "address",
                "value": "Dubai"
                },
                {
                "name": "anniversary",
                "value": "10-04-2015"
                },
                {
                "name": "birthday",
                "value": "10-04-1987"
                },
                {
                "name": "nationality",
                "value": "Dubai"
                },
                {
                "name": "gender",
                "value": "Male"
                }
              ]
            }
          }
        } 
      EOS
      formats ['json']
      def customer_profile_update
        hash = {}
        initheader = { 'Content-Type' => 'application/json',Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
        url = "http://api.capillary.co.in/v1.1/customer/update?format=json"
        hash["root"] = params[:root]
        payload = hash.to_json
        @response = RestClient.post(url,payload,initheader)
      end

      api :POST, '/api/v2/boutique_capillaries/regular_transaction_add', "Update customer in BoutiqueCpaillaries (Authorization header required)."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :root, Hash, :required => true, :desc => <<-EOS
          ==== A sample parameter value is given below
          {
            "transaction": [{
            "type": "regular",
            "number": "MyBill-5627",
            "amount": "10000",
            "billing_time": "2016-02-02 14:32:29",
            "gross_amount": "10000",
            "discount": "0", 
            "customer": {
              "mobile": "919674442296",
              "email": "gobinda@gmail.com",
              "firstname": "Gobinda",
              "lastname": "Saha"
              },
            "payment_details": {
              "payment": [{
              "mode": "Cash",
              "value": "11"
              }, 
              {
              "mode": "Card",
              "value": "12",
              "attributes": {
              "attribute": {
              "name": "card_type",
              "value": "CREDIT"
              }
              }
              }]
              },
            "line_items": {
              "line_item": [{
                "serial": "1",
                "amount": "40", 
                "description": "Pharma",
                "item_code": "1234",
                "qty": "1",
                "discount": "10",
                "rate": "30",
                "value": "30"
                }, 
                {
                "serial": "2",
                "amount": "30", 
                "description": "Pharma", 
                "item_code": "1235",
                "qty": "1",
                "discount": "0",
                "rate": "30",
                "value": "30"
                }]
              }
            }]
          }
          EOS
      formats ['json']
      def regular_transaction_add
        hash = {}
        initheader = { 'Content-Type' => 'application/json',Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
        url = "http://api.capillary.co.in/v1.1/transaction/add?format=json"
        hash["root"] = params[:root]
        payload = hash.to_json
        @response = RestClient.post(url,payload,initheader)
        if JSON.parse(@response)["response"]["status"]["success"] == false
          @error = @response
        end
      end

      api :POST, '/api/v2/boutique_capillaries/loyality_bill_full_return', "Loyality bill return in BoutiqueCpaillaries (Authorization header required)."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :root, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
        {
          "transaction": [{
          "type": "return",
          "return_type": "FULL ", 
          "number": "9668",
          "amount": "5000",
          "billing_time": "2016-02-02 14:34:29",
          "gross_amount": "5000",
          "discount": "0", 
          "customer": {
          "mobile": "919674442296",
          "email": "gobinda@gmail.com",
          "firstname": "Gabinda",
          "lastname": "Ghosh"
          },
          "line_items": {
            "line_item": [{
              "amount": "40", 
              "description": "Pharma",
              "item_code": "1234",
              "qty": "1",
              "discount": "10",
              "rate": "50",
              "value": "50"
              },
              {
              "amount": "30", 
              "description": "Pharma",
              "item_code": "1235",
              "qty": "1",
              "discount": "0",
              "rate": "30",
              "value": "30"
              }
            ]
          }
          }
          ]
        }
      EOS
      def loyality_bill_full_return
        hash = {} 
        initheader = { 'Content-Type' => 'application/json',Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
        url = "http://api.capillary.co.in/v1.1/transaction/add?format=json"
        hash["root"] = params[:root]
        payload = hash.to_json
        @response = RestClient.post(url,payload,initheader)
        if JSON.parse(@response)["response"]["status"]["success"] == false
          @error = @response
        end
      end

      api :POST, '/api/v2/boutique_capillaries/loyality_bill_amount_return', "Loyality amount return in BoutiqueCpaillaries (Authorization header required)."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :root, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
        {
          "transaction": [{
            "type": "return",
            "return_type": "AMOUNT",
            "number": "9677",
            "amount": "4000",
            "billing_time": "2016-02-02 14:35:29",
            "gross_amount": "4000",
            "discount": "30",
            "customer": {
            "mobile": "919674442296",
            "email": "gobinda@gmail.com",
            "firstname": "Gobinda",
            "lastname": "Ghosh"
            },    
          "line_items": {
            "line_item": [
              {
              "amount": "40", 
              "description": "Pharma",
              "item_code": "1234",
              "qty": "1",
              "discount": "10",
              "rate": "50",
              "value": "50"
              },
              {
              "amount": "30", 
              "description": "Pharma",
              "item_code": "1235",
              "qty": "1",
              "discount": "0",
              "rate": "30",
              "value": "30"
              }
              ]
            }
          }]
        }
      EOS

      def loyality_bill_amount_return
        hash = {}
        initheader = { 'Content-Type' => 'application/json',Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
        url = "http://api.capillary.co.in/v1.1/transaction/add?format=json"
        hash["root"] = params[:root]
        payload = hash.to_json
        @response = RestClient.post(url,payload,initheader)
        if JSON.parse(@response)["response"]["status"]["success"] == false
          @error = @response
        end
      end

      api :POST, '/api/v2/boutique_capillaries/loyality_bill_line_item_return', "Bill line item return transaction in BoutiqueCpaillaries (Authorization header required)."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :root, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
        {
          "transaction": [{
            "type": "return",
            "return_type": "LINE_ITEM",
            "number": "542",
            "amount": "15000",
            "purchase_time": "2016-02-02",
            "billing_time": "2016-02-02 15:35:29",
            "gross_amount": "15000",
            "discount": "0",
          "line_items": {
            "line_item": [
              {
              "amount": "40", 
              "description": "Pharma",
              "item_code": "1234",
              "qty": "1",
              "discount": "10",
              "rate": "50",
              "value": "50"
              },
              {
              "serial": "2",
              "amount": "30",
              "description": "Pharma",
              "item_code": "1235",
              "qty": "1",
              "discount": "0",
              "rate": "30",
              "value": "30"
              }
            ]
          }
        }]
      }
      EOS
      def loyality_bill_line_item_return
        hash = {}
        initheader = { 'Content-Type' => 'application/json',Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
        url = "http://api.capillary.co.in/v1.1/transaction/add?format=json"
        hash["root"] = params[:root]
        payload = hash.to_json
        @response = RestClient.post(url,payload,initheader)
        if JSON.parse(@response)["response"]["status"]["success"] == false
          @error = @response
        end
      end

      # # def loyality_mixed_return
      # #   hash = {}
      # #   initheader = { 'Content-Type' => 'application/json',Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
      # #   url = "http://api.capillary.co.in/v1.1/transaction/add?format=json"
      # #   hash
      # # end
      # api :POST, '/api/v2/boutique_capillaries/non_loyality_bill_return', "Non loyality in BoutiqueCpaillaries (Authorization header required)."
      # param :email, String, :required => true, :desc => "Email ID of user."
      # param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      # param :root, Hash, :required => true, :desc => <<-EOS
      #   ==== A sample parameter value is given below
      #   {
      #     "transaction": [{
      #       "type": "not_interested_return",
      #       "return_type": "FULL",
      #       "number": "MyBill-1022",
      #       "amount": "60",
      #       "purchase_time": "2016-02-02",
      #       "billing_time": "2016-02-02 15:35:29",
      #       "gross_amount": "70",
      #       "discount": "0", 
      #     "line_items": { 
      #       "line_item": [
      #         {
      #         "amount": "40",
      #         "description": "Pharma", 
      #         "item_code": "1234",
      #         "qty": "1",
      #         "discount": "10",
      #         "rate": "50",
      #         "value": "50"
      #         },
      #         {
      #         "amount": "30",
      #         "description": "Pharma",
      #         "item_code": "1235",
      #         "qty": "1",
      #         "discount": "0",
      #         "rate": "30",
      #         "value": "30"
      #         }
      #       ]
      #     }
      #     }]
      #   }
      # EOS
      # def non_loyality_bill_return
      #   hash = {}
      #   initheader = { 'Content-Type' => 'application/json',Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
      #   url = "http://api.capillary.co.in/v1.1/transaction/add?format=json"
      #   hash["root"] = params[:root]
      #   payload = hash.to_json
      #   @response = RestClient.post(url,payload,initheader)
      # end

      # api :POST, '/api/v2/boutique_capillaries/non_loyality_amount_return', "Nonloyality amount return in BoutiqueCpaillaries (Authorization header required)."
      # param :email, String, :required => true, :desc => "Email ID of user."
      # param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      # param :root, Hash, :required => true, :desc => <<-EOS
      #   ==== A sample parameter value is given below
      #   {
      #     "transaction": [{
      #       "type": "not_interested_return",
      #       "return_type": "FULL",
      #       "number": "242756",
      #       "amount": "15000",
      #       "purchase_time": "2016-02-02",
      #       "billing_time": "2016-02-02 15:35:29",
      #       "gross_amount": "15000",
      #       "discount": "0",
      #     "line_items": {
      #       "line_item": [
      #         {
      #         "serial": "1",
      #         "amount": "40", 
      #         "description": "Pharma",
      #         "item_code": "1234",
      #         "qty": "1",
      #         "discount": "10",
      #         "rate": "50",
      #         "value": "50"
      #         },
      #         {
      #         "serial": "2",
      #         "amount": "30", 
      #         "description": "Pharma",
      #         "item_code": "1235",
      #         "qty": "1",
      #         "discount": "0",
      #         "rate": "30",
      #         "value": "30"
      #         }
      #       ]
      #     }
      #     }]
      #   }
      # EOS
      # def non_loyality_amount_return
      #   hash = {}
      #   initheader = { 'Content-Type' => 'application/json',Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
      #   url = "http://api.capillary.co.in/v1.1/transaction/add?format=json"
      #   hash["root"] = params[:root]
      #   payload = hash.to_json
      #   @response = RestClient.post(url,payload,initheader)
      # end

      # api :POST, '/api/v2/boutique_capillaries/non_loyality_amount_return', "Update customer in BoutiqueCpaillaries (Authorization header required)."
      # param :email, String, :required => true, :desc => "Email ID of user."
      # param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      # param :root, Hash, :required => true, :desc => <<-EOS
      #   ==== A sample parameter value is given below
      #   {
      #     "transaction": [{
      #       "type": "not_interested_return",
      #       "return_type": "LINE_ITEM", 
      #       "number": "242756",
      #       "amount": "15000",
      #       "purchase_time": "2016-02-02",
      #       "billing_time": "2016-02-02 15:35:29",
      #       "gross_amount": "15000",
      #       "discount": "0",
      #     "line_items": {
      #       "line_item": [
      #       {
      #       "amount": "40", 
      #       "description": "Pharma", 
      #       "item_code": "1234",
      #       "qty": "1",
      #       "discount": "10",
      #       "rate": "50",
      #       "value": "50"
      #       },
      #       {
      #       "amount": "30",
      #       "description": "Pharma",
      #       "item_code": "1235",
      #       "qty": "1",
      #       "discount": "0",
      #       "rate": "30",
      #       "value": "30"
      #       }
      #     ]}
      #     }]
      #   }
      # EOS
      # def non_loyality_line_item_return
      #   hash = {}
      #   initheader = { 'Content-Type' => 'application/json',Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
      #   url = "http://api.capillary.co.in/v1.1/transaction/add?format=json"
      #   hash["root"] = params[:root]
      #   payload = hash.to_json
      #   @response = RestClient.post(url,payload,initheader)
      # end

      api :GET, '/api/v2/boutique_capillaries/validation_code', "Validation code generate for point redeemption in BoutiqueCpaillaries (Authorization header required)."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)." 
      param :mobile, String, :desc => "The phone number of the customer", :required => true
      param :points, String, :desc => "Point which we want to redeem", :required => false

      def validation_code
        headers = {Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
        url = "http://api.capillary.co.in/v1.1/points/validationcode?mobile=#{params[:mobile]}&points=#{params[:points]}&format=json"
        @response = RestClient::Request.execute(method: :get, url: url, headers: headers)
        if JSON.parse(@response)["response"]["status"]["success"] == false
          @error = @response
        end
      end

      api :POST, '/api/v2/boutique_capillaries/point_redeem', "Point redeemtion in BoutiqueCpaillaries (Authorization header required)."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :root, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
        {
          "redeem": {
          "points_redeemed": "10",
          "discount": "10",
          "validation_code":"3CWW8B",
          "customer": {
            "mobile": "919674442296"
          },
          "notes": "asdfassd"   
          }
        }
        EOS
  
      def point_redeem
        hash = {}
        initheader = {'Content-Type' => 'application/json',Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
        url = "https://api.capillary.co.in/v1.1/points/redeem?format=json"
        hash["root"] = params[:root]
        payload = hash.to_json
        @response = RestClient.post(url,payload,initheader)
        if JSON.parse(@response)["response"]["status"]["success"] == "false"
          @error = @response
        end
      end

      api :GET, '/api/v2/boutique_capillaries/check_coupon', "Check coupon for coupon redeemption in BoutiqueCpaillaries (Authorization header required)."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)." 
      param :mobile, String, :desc => "The phone number of the customer", :required => true
      param :code, String, :desc => "When purchase something coupon code generated on customer's phone by sms", :required => true

      def check_coupon
        headers = {Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
        url = "http://api.capillary.co.in/v1.1/coupon/isredeemable?mobile=#{params[:mobile]}&code=#{params[:code]}&details=true&format=json"
        @response = RestClient::Request.execute(method: :get, url: url, headers: headers)
        if JSON.parse(@response)["response"]["status"]["success"] == "false"
          @error = @response
        end
        puts @error
      end

      api :POST, '/api/v2/boutique_capillaries/coupon_redeem', "Coupon redeemtion in BoutiqueCpaillaries (Authorization header required)."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :root, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
          {
            "coupon": {
              "code": "4AICSDT1",
              "customer": {
               "mobile": "919475236033"
                },
              "transaction": {
                "number": "9669",
                "amount": "320",
                "discount" : "320"
              }
            }
          }
        }
      EOS

      def coupon_redeem
        hash = {}
        initheader = {'Content-Type' => 'application/json' ,Authorization: 'Basic ZGVtby5wYXdhbjE6NjJjYzJkOGI0YmYyZDg3MjgxMjBkMDUyMTYzYTc3ZGY='}
        url = "https://api.capillary.co.in/v1.1/coupon/redeem?format=json"
        hash["root"] = params[:root]
        payload = hash.to_json
        @response = RestClient.post(url,payload,initheader)

        if JSON.parse(@response)["response"]["status"]["success"] == "false"
          @error = @response
        end
      end
      

    end
  end
end



