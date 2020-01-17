module Api
  module V2
    class UsersController < ApplicationController
      before_filter :authenticate_user_with_token!, only: [:logout]

      api :GET, '/api/v2/users/', "API to fetch list of users."
      param :email, String, :required => true, :desc => "required email of user"
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required=>false, :desc =>"if you want to fetch users of a specific unit"
      def index
        if params[:unit_id].present?
          @users = User.by_unit(params[:unit_id]).by_status(1).includes([:profile,:users_role,:unit])
        else
          @users = User.by_status(1).includes([:profile,:users_role,:unit])
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception   
      end


      api :GET, '/api/v2/users/:id', "API to fetch a user."
      param :email, String, :required => true, :desc => "required email of user"
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      def show
        @user = User.find(params[:id])
        rescue Exception => @error              
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception           
      end 

      ### => API Documentation (APIPIE) for 'login' action
      api :POST, '/api/v2/users/login', "User login."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email_id, String, :required => true, :desc => "Email ID or user"
      param :password, String, :required => true, :desc => "User's password."
      param :device_id, String, :required => true, :desc => "Device ID."
      param :resources, String, :required => false, :desc => "This parameter defines, how many extra resources, associated with this user will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :meta => {:allowed_resources => ["capabilities"], :example => "resources=capabilities"}
      formats ['json']
      description <<-EOS
        EOS
      example '
      Success Response (POST Request: http://dev.selfordering.com/api/v2/users/login?resources=capabilities)
        {
          "status": "ok",
          "messages": {
            "simple_message": "Logged in successfully.",
            "internal_message": "Logged in successfully."
          },
          "data": {
            "id": 12,
            "email": "ram@gmail.com",
            "unit_id": 5,
            "key_phrase": "2498",
            "firstname": "RAM",
            "lastname": "SHARMA",
            "contact_no": "111111111",
            "capabilities": {
              "Bill": [
                "cannot :create",
                "cannot :index",
                "cannot :show",
                "cannot :split_bill",
                "cannot :update"
              ],
              "Settlement": [
                "cannot :create",
                "cannot :update"
              ],
              "Order": [
                "cannot :cancel_order",
                "cannot :create",
                "cannot :destroy",
                "cannot :edit",
                "cannot :show",
                "cannot :trash"
              ]
            },
            "last_bill_serial": "4",
            "currency": "Rs",
            "push_server_ip": "192.168.9.47"
          }
        }

      Error Response (POST Request: http://dev.selfordering.com/api/v2/users/login?resources=capabilities)

        {
          "status": "error",
          "messages": {
            "simple_message": "You have entered incorrect email or password",
            "internal_message": "You have entered incorrect email or password",
            "error_code": "",
            "error_url": ""
          },
          "data": {}
        }
      '
      ### => 'login' API
      def login
        @user = User.find_by_email(params[:email_id])
        puts @user.inspect
        @user_unit = @user.unit
        raise "You have entered incorrect email or password" unless @user.present? and @user.valid_password?(params[:password])
        raise "User account is disabled" if @user.status == 0 or @user.is_trashed == true
        @capabilities = @user.role.capabilities.present? ? capability_hash(JSON.parse(@user.role.capabilities)) : Hash.new
        @resources = params[:resources].split(',') if params[:resources].present?
        @last_bill_serial = Bill.last_serial_number(@user.unit_id,params[:device_id])
        @last_proforma_serial = Proforma.last_serial_number(@user.unit_id,params[:device_id])
        UserLoginLogout.create(:user_role_name => @user.users_role.role.name, :unit_id => @user.unit_id, :unit_name => @user.unit.unit_name, :sign_in_at => Time.now, :user_id => @user.id, :device_identity => params[:device_id])
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'logout' action
      api :POST, '/api/v2/users/logout', "User logout. (Authorization header required for authentication)"
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => true, :desc => "Email ID or user"
      param :device_id, String, :required => true, :desc => "Device ID."
      formats ['json']
      ### => 'logout' API
      def logout
        @user = User.find_by_email(params[:email])
        @user.update_token!
        @user.user_login_logouts.by_device_identity(params[:device_id]).last.update_column(:sign_out_at, Time.now) if @user.user_login_logouts.by_device_identity(params[:device_id]).present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'logout' action
      api :POST, '/api/v2/users/create_live_map_points', "Create live map points for user."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :email, String, :required => true, :desc => "Email ID or user"
      param :device_id, String, :required => true, :desc => "Device ID."
      param :live_map_data, Hash, :required => true, :desc => <<-EOS
          ==== A sample parameter value is given below
            {
              "user_id":7,
              "latitude":"88.00",
              "longitude":"22.00",
              "duration":"12:30:40",
              "recorded_at":"2019-05-14 22:10:20",
              "subdomain":"silvershine"
            }
        EOS
      formats ['json']
      ### => 'logout' API
      def create_live_map_points
        # @live_map_data = LiveMapPoint.new(params[:live_map_data])
        # @live_map_data.save
        # rescue Exception => @error
        # @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def verify_license
        @subdomain = Subdomain.find_by_auth_key(params[:license_key])
        raise I18n.t(:error_invalid_license_key) unless @subdomain.present?
        @account = Account.by_subdomain(@subdomain.schema_name)
        raise I18n.t(:error_invalid_license_key) if @account.present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentatation (APIPIE) for 'get_user_incentive' action
      api :GET, 'api/v2/users/get_user_incentive', "list of user incentive"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :user_id, String, :required=> true

      def get_user_incentive
        rescue Exception => e
        @log = Rscratc6::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentatation (APIPIE) for 'user_group_data' action
      api :GET, 'api/v2/users/user_group_data', "list of user target data"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :user_id, String, :required=> true

      def user_group_data
        @quarter = ((Time.now.month - 1) / 3) + 1
        rescue Exception => e
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def get_users_by_role
        @users = User.by_role(params[:role_id])
      end
      
      private

      def capability_hash(_auths,_hash={})
        _auths["default"].each do |au|
          _result = au.split(", ")
          if _hash.has_key?(_result[1])
            _inarr = _hash[_result[1]]
            _inarr.push(_result[0])
            _hash[_result[1]] = _inarr
          else
            _inarr = Array.new
            _inarr.push(_result[0])
            _hash[_result[1]]=_inarr
          end
        end
        return _hash
      end
    end
  end
end
