module Api
  module V2
    class CustomersController < ApplicationController 
      #before_filter :authenticate_user_with_token!

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/customers', "Register new customer (Authorization header required / App authentication required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => false, :desc => "Email ID of user, who is registering the user."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :customer_email, String, :required => false, :desc => "Email ID of customer (Optional)."
      param :customer_password, String, :required => false, :desc => "Password of customer (Optional)."
      param :firstname, String, :desc => "First name of customer.", :required => false
      param :lastname, String, :desc => "Last name of customer.", :required => false
      param :gstin, String, :desc => "Gstin of customer.", :required => false
      param :business_type, String, :desc => "Business type of customer.", :required => false
      param :contact_no, String, :desc => "Customer's contact number.", :required => false
      param :address, String, :desc => "Customer's address.", :required => false
      param :gender, String, :desc => "Customer's gender.", :required => false
      param :age, String, :desc => "Customer's age.", :required => false
      param :dob, String, :desc => "Customer's date of birth.", :required => false
      param :profile_url, String, :desc => "Customer facebook profile url", :required => false
      param :picture_url, String, :desc => "customer facebook picture url", :required => false
      param :fb_id, String, :desc => "customer facebook id", :required => false
      param :anniversary, String, :desc => "Customer's anniversary.", :required => false
      param :queue, String, :desc => "Optional param to check queue creation", :required => false, :meta => "`queue` value should be 'Yes'"
      param :resource_id, String, :desc => "Resource id of this new customer", :required => false
      param :day, String, :desc => "day required to assign the sales person", :required => false
      param :user_id, String, :desc => "id of the sales person", :required => false
      param :customer_state_id, String, :desc => "id of the Customer state", :required => false
      param :financial_account, String, :desc => "Optional param to create financial account creation", :required => false, :meta => "`financial_account` value should be 'Yes'"
      param :wallet, String, :desc => "Optional param to create wallet creation", :required => false, :meta => "`wallet` value should be 'Yes'"
      param :customer, Hash, :required => false, :desc => <<-EOS

        ==== A sample parameter value is given below
          {
           "email": "g@gmail.com",
           "mobile_no": 8907654213,
           "password": "12345678",
           "customer_state_id": 1,
           "business_type": "b2b",
           "gstin": "234rtyu",
           "customer_profile_attributes": {
             "firstname": "gobinda",
             "lastname": "Manna",
             "contact_no": "8907654213",
             "address": "kolkta",
             "gender": "Male",
             "age": "28",
             "dob": "2018-05-11",
             "anniversary": 3
           },
           "addresses_attributes": [
             {
               "receiver_first_name": "G",
               "receiver_last_name": "M",
               "contact_no": "9076879089",
               "delivery_address": "Kolkata",
               "locality": "Kolkata",
               "landmark": "Behala",
               "city": "Kolkata",
               "state": "West Bengal",
               "pincode": "789098",
               "latitude": "7890987",
               "longitude": "9087655",
               "address_type" : "home"
             }
           ],
           "resource_attributes": {
             "name": "kakai",
             "resource_type_id": 1,
             "unit_id": 7,
             "section_id": 3,
             "resource_state_id": 1,
             "status": "enabled",
             "user_id": 1,
             "unique_identity_no":"1234ABS1234",
             "user_resources_attributes": [
              {
                "day": "Sunday",
                "user_id": 2
              },
              "bit_resources_attributes": [
              {
                "bit_id": 2
              }
            ]
           }
          }
        EOS
      formats ['json']
      ### => 'create' API Defination
      def create
        #if params[:queue].present? and params[:queue] == 'Yes'
        if params[:address] == 'Yes'
          @customer = Customer.new(params[:customer])
          @customer.password = "12345678"
          if @customer.save
            @customer.reload
          else
            @validation_errors = error_messages_for(@customer)
          end
        elsif params[:resource].present? and params[:resource] == 'Yes'
          @customer = Customer.find_by_mobile_no(params[:customer][:mobile_no]) if params[:customer][:mobile_no].present? 
          if @customer.present?
            if @customer.resource.present?
              user_resource = params[:customer][:resource_attributes][:user_resources_attributes]
              UserResource.create(:visit_date => user_resource[0]["visit_date"], :resource_id => @customer.resource.id,:user_id => user_resource[0]["user_id"])
              @status_code = 406
              @status_messge = "Customer exit with this mobile no"
            else
              resource = Resource.new(params[:customer][:resource_attributes])
              resource.customer_id = @customer.id
              if resource.save
                # user_resource = params[:customer][:resource_attributes][:user_resources_attributes]
                # UserResource.create(:day => user_resource[0]["day"], :resource_id => resource.id,:user_id => user_resource[0]["user_id"])
                @status_code = 406
                @status_messge = "Customer exit with this mobile no."
              end
            end
          else  
            @customer = Customer.new(params[:customer])
            @customer.customer_state_id = 1
            if @customer.save
              UnitCustomer.create(:customer_id => @customer.id, :unit_id => @customer.resource.unit_id) if @customer.resource.present?
              if params[:financial_account] == 'Yes'
                unless @customer.financial_account.present?
                  @customer_account = FinancialAccount.new
                  @customer_account.account_holder_id = @customer.id
                  @customer_account.account_holder_type = "Customer"
                  @customer_account.account_type = "buyer"
                  @customer_account.save
                end    
              end 
              if params[:wallet] == 'Yes'
                unless @customer.wallet.present?
                  @customer_wallet = Wallet.new
                  @customer_wallet.customer_id = @customer.id
                  @customer_wallet.current_balance = 0
                  @customer_wallet.total_credit = 0
                  @customer_wallet.total_debit = 0
                  @customer_wallet.save
                end    
              end 
              @customer.reload
            else
              @validation_errors = error_messages_for(@customer)
            end
          end  
        else      
          @customer = Customer.new(customer_params)
          if @customer.save
            if params[:financial_account] == 'Yes'
              unless @customer.financial_account.present?
                @customer_account = FinancialAccount.new
                @customer_account.account_holder_id = @customer.id
                @customer_account.account_holder_type = "Customer"
                @customer_account.account_type = "buyer"
                @customer_account.save
              end    
            end 
            if params[:wallet] == 'Yes'
              unless @customer.wallet.present?
                @customer_wallet = Wallet.new
                @customer_wallet.customer_id = @customer.id
                @customer_wallet.current_balance = 0
                @customer_wallet.total_credit = 0
                @customer_wallet.total_debit = 0
                @customer_wallet.save
              end    
            end 
            @customer.reload
          else
            @validation_errors = error_messages_for(@customer)
          end
        end  
        @customer.reload
        #raise "#{@customer[:error]}" if @customer[:error].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'login' action
      api :POST, '/api/v2/customers/login', "Customer Login (Authorization header required / App authentication required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => false, :desc => "Email ID of user, who is sending the order."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :login, String, :desc => "Registered email ID or mobile number of customer.", :required => true
      param :password, String, :desc => "Password of customer.", :required => true
      formats ['json']
      ### => 'login' API Defination
      def login
        @customer = Customer.where("email = ? OR mobile_no = ?", params[:login], params[:login]).first
        raise "Invalid login credentials, please try again" unless @customer.present? and @customer.valid_password?(params[:password])
        raise "#{@customer[:error]}" if @customer[:error].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
      
      ### => API Documentation (APIPIE) for 'login_by_otp' action
      api :POST, '/api/v2/customers/login_by_otp', "API to generate OTP for login/register (Authorization header required / App authentication required)."
      param :email, String, :required => false, :desc => "Email ID of user"
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :contact_no, String, :required => false, :desc => "contact no. of customer,where the OTP wil be sent"
      #######################################################

      #user login by otp
      def login_by_otp  
        @customer_login = Customer.where(:mobile_no => params[:contact_no]).first
        if @customer_login.present?
          send_otp
        else
          @customer_login= Customer.new(customer_params)
          if @customer_login.save
            send_otp
          end
        end
      end

      ### => API Documentation (APIPIE) for 'login_by_otp' action
      api :POST, '/api/v2/customers/verify_otp', "API to verify OTP (Authorization header required / App authentication required)."
      param :email, String, :required => true, :desc => "Email ID of use."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :id, String, :required => true, :desc => "id for the OTP returned as a response to 'login_by_otp' API call"
      param :otp, String, :required => true, :desc => "This is the OTP sent to the mobile number"
      param :contact_no, String, :required => true, :desc => "the contact number"
    
      ######################################################

      def verify_otp
        @otp=Otp.find_by_id(params[:id])
        if @otp.verified
          @manual_error="can not be verified"
          # @error={"message"=>"can not be verified"}
        else
          if @otp.phone_number==params[:contact_no] and @otp.otp==params[:otp]
            @otp.verify()
          else
            @manual_error="can not be verified"
          # @error={"message"=>"can not be verified"}
          end
        end
      end

      ### => API Documentation (APIPIE) for 'find_by_login' action
      api :POST, '/api/v2/customers/find_by_login', "Fetch customer details by email or mobile number (Authorization header required / App authentication required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => false, :desc => "Email ID of user, who is sending the order."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :login, String, :desc => "Registered email ID or mobile number of customer.", :required => true
      param :boh_amount, String, :desc => "Boh amount of customer.", :required => false
      param :unit_id, String, :desc => "Current user id.", :required => false
      param :resources, String, :desc => "This parameter defines, how many extra resources, associated with customer will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :required => false, :meta => {:allowed_resources => ["financial_account","wallet"], :example => "resources=financial_account "}
      formats ['json']
      ### => 'find_by_login' API Defination
      # def find_by_login
      #   @customer = Customer.find(:first, :conditions=>["email = ? OR mobile_no = ?", params[:customer_login], params[:customer_login]])
      #   raise "#{@customer[:error]}" if @customer[:error].present?
      #   rescue Exception => @error
      #   @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      # end

      def find_by_login
        @customer = Customer.by_identification(params[:login]).first if params[:login].present? 
        @customer_profile = @customer.profile if @customer.present?
        if @customer.present?
          @boh_amount = Bill.select("sum(boh_amount) as total_boh_amount").unit_bills(params[:unit_id]).by_customer(@customer.id) if params[:boh_amount].present? && params[:boh_amount] == 'yes'
        end
        @resources = params[:resources].present? ? params[:resources].split(',') : Array.new
        raise "No record found" if @customer[:error].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :POST, '/api/v2/customers/search_by_customer_name',"Get customer name by shortcut search"
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => false, :desc => "Email ID of user, who is sending the order."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :cust_name, String, :required => false, :desc => "Search by customer name"


      def search_by_customer_name
        @customers = Customer.by_customer_name_search(params[:cust_name]) if params[:cust_name].present?
        #raise "No record found" if @customers[:error].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
      
      ### => API Documentation (APIPIE) for 'add_address' action
      api :POST, '/api/v2/customers/add_address', "Add new delivery address of a customer (Authorization header required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :customer_id, String, :desc => "Customer ID.", :required => true
      param :first_name, String, :desc => "First name of the person who will receive this order.", :required => false
      param :last_name, String, :desc => "Last name of the person who will receive this order.", :required => false
      param :contact_no, String, :desc => "Contact number of the person who will receive this order.", :required => true
      param :delivery_address, String, :desc => "Delivery address.", :required => true
      param :locality, String, :desc => "Locality of the delivery address.", :required => false
      param :landmark, String, :desc => "Nearby landmark.", :required => false
      param :city, String, :desc => "City name.", :required => false
      param :state, String, :desc => "State name.", :required => false
      param :pincode, String, :desc => "Pincode.", :required => true
      param :latitude, String, :desc => "Latitude.", :required => false
      param :longitude, String, :desc => "Longitude.", :required => false
      param :address_type, String, :desc => "home/office/work.", :required => false
      formats ['json']
      ### => 'find_by_login' API Defination
      def add_address
        @address = Address.new(address_params)
        @address.save
        raise "#{@address[:error]}" if @address[:error].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'create' action
      api :PUT, '/api/v2/customers/:id', "Update exting customer (Authorization header required / App authentication required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => false, :desc => "Email ID of user, who is registering the user."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :firstname, String, :desc => "First name of customer.", :required => false
      param :lastname, String, :desc => "Last name of customer.", :required => false
      param :gstin, String, :desc => "Gstin of customer.", :required => false
      param :business_type, String, :desc => "Business type of customer.", :required => false
      param :address, String, :desc => "Customer's address.", :required => false
      param :gender, String, :desc => "Customer's gender.", :required => false
      param :age, String, :desc => "Customer's age.", :required => false
      param :dob, String, :desc => "Customer's date of birth.", :required => false
      param :anniversary, String, :desc => "Customer's anniversary.", :required => false
      param :profile_id, String, :desc => "Profile id of that customer.", :required => true
      formats ['json']
      ### => 'create' API Defination
      def update
        @customer = Customer.find(params[:id])
        if @customer.update_attributes(customer_profile_params)
          @customer.reload
        end  
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :GET, '/api/v2/customers/forgot_password', "Customer check and otp genarate for mobile no (Authorization header required / App authentication required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => false, :desc => "Email ID of user, who is sending the order."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :mobile_no, String, :desc => "Registered email ID or mobile number of customer.", :required => true
      formats ['json']
      def forgot_password
        @customer = Customer.by_identification(params[:mobile_no])
        if @customer.present?
          @phone_number = Otp.new()
          @phone_number.phone_number = params[:mobile_no]
          @phone_number.save
          @phone_number.generate_pin
          @phone_number.send_pin
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :PUT, '/api/v2/customers/reset_password', "Password reset for a customer (Authorization header required / App authentication required)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => false, :desc => "Email ID of user, who is sending the order."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :mobile_no, String, :desc => "Registered email ID or mobile number of customer.", :required => true
      param :password, String, :required => true, :desc => "Password of customer account."
      formats ['json']
      def reset_password
        @customer = Customer.by_identification(params[:mobile_no]).first
        if @customer.update_attributes(reset_password_params)
          @customer.reload
        end  
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :POST, '/api/v2/customers/add_financial_account',"Crate financial account."
      param :email, String, :required => false, :desc => "Email ID of user, who is sending the order."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."            
      param :customer_id, String, :desc => "customer id of registered customer.", :required => true
      def add_financial_account
        ActiveRecord::Base.transaction do
          @customer = Customer.find(params[:customer_id])
          if @customer.present?
            raise "Account already exists for #{@customer.customer_profile.customer_name}" if @customer.financial_account.present?
            @customer_account = FinancialAccount.new
            @customer_account.account_holder_id = params[:customer_id]
            @customer_account.account_holder_type = "Customer"
            @customer_account.account_type = "buyer"
            if @customer_account.save
              @customer_account.reload
            else  
              @validation_errors = error_messages_for(@customer_account)
            end
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def account_transaction_history
        @customer = Customer.find(params[:customer_id])
        if @customer.present?
          @customer_financial_account = @customer.financial_account
          if @customer_financial_account.present?
            @account_transactions = @customer_financial_account.financial_account_transactions.order("id desc").limit(10)
          end
        end
      end

      private
      def send_otp
        @phone_number = Otp.new()
        @phone_number.phone_number = params[:contact_no]
        @phone_number.save
        @phone_number.generate_pin
        @phone_number.send_pin
      end

      def customer_params      
        { 
          "email"                         => params[:customer_email],
          "mobile_no"                     => params[:contact_no],
          "password"                      => params[:customer_password] || "12345678",
          "gstin"                         => params[:gstin],
          "business_type"                 => params[:business_type],
          "fb_id"                         => params[:fb_id],

          "customer_profile_attributes" =>
          {
            "firstname" => params[:firstname],
            "lastname" => params[:lastname],
            "contact_no" => params[:contact_no],
            "address" => params[:address],
            "gender" => params[:gender],
            "age" => params[:age],
            "dob" => params[:dob],
            "anniversary" => params[:anniversary],
            "picture_url" => params[:picture_url],
            "profile_url" => params[:profile_url]
            #"customer_identification" => params[:customer_identification]
          }
          
          # ,
          # "addresses_attributes" =>
          # {"0"=>{
          #   "receiver_first_name" => params[:first_name],
          #   "receiver_last_name"  => params[:last_name],
          #   "contact_no"          => params[:contact_no],          
          #   "delivery_address"    => params[:delivery_address],
          #   "locality"            => params[:locality],
          #   "landmark"            => params[:landmark],
          #   "city"                => params[:city],
          #   "state"               => params[:state],
          #   "pincode"             => params[:pincode],
          #   "latitude"            => params[:latitude],
          #   "longitude"           => params[:longitude]
          #   }
          # }          
        }
      end

      def customer_profile_params      
        { 
          "gstin"                         => params[:gstin],
          "business_type"                 => params[:business_type],

          "customer_profile_attributes" =>
          {
            "id"          => params[:profile_id],
            "firstname"   => params[:firstname],
            "lastname"    => params[:lastname],
            "address"     => params[:address],
            "gender"      => params[:gender],
            "age"         => params[:age],
            "dob"         => params[:dob],
            "anniversary" => params[:anniversary]
          }       
        }
      end

      def customer_login_params
        {
          "login"     => params[:login],
          "password"  => params[:password]
        }
      end

      def reset_password_params
        {
          "password"  => params[:password]
        }
      end

      def address_params
        {
          "customer_id"         => params[:customer_id],
          "receiver_first_name" => params[:first_name],
          "receiver_last_name"  => params[:last_name],
          "contact_no"          => params[:contact_no],          
          "delivery_address"    => params[:delivery_address],
          "locality"            => params[:locality],
          "landmark"            => params[:landmark],
          "city"                => params[:city],
          "state"               => params[:state],
          "pincode"             => params[:pincode],
          "latitude"            => params[:latitude],
          "longitude"           => params[:longitude],
          "address_type"           => params[:address_type]
        }
      end
    end
  end
end
