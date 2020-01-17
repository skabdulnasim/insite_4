module Api
  module V2
    class ResourcesController < ApplicationController 
      before_filter :authenticate_user_with_token!, only: [:update, :swap_resource, :resource_pjp, :get_available_resource, :by_unique_identity_no]

      api :GET, '/api/v2/resources', "List of all resources (Authorization header required for authentication)."
      param :email, String, :required => true, :desc => "required email of user"
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => false, :desc => "Filter resources of an unit"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"      
      param :section_id, String, :required => false, :desc => "Filter by section ID"
      param :resource_type_id, String, :required => false, :desc => "Filter by resource_type"
      param :resource_state_id, String, :required => false, :desc => "Filter by resource status ID"
      param :reservation_date, String, :required => false, :desc => "Avaliable resource for a day "
      param :start_date, String, :required => false, :desc => "start_date is required"
      param :end_date, String, :required => false, :desc => "end_date is required"
      param :data_count,String, :required => false, :desc=> "The value of date_count param is 'yes'."
      param :slot_id, String, :required => false, :desc => "Slot id"
      param :resources, String, :desc => "This parameter defines, how many extra resources, associated with bill will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :required => false, :meta => {:allowed_resources => ["menu_product"], :example => "resources=menu_product"}
      
      def index
        @data_count = params[:data_count]
        _per = params[:count] || 20
        _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
        if params[:start_date].present?
          _from_datetime = DateTime.parse(params[:start_date]).strftime("%Y-%m-%d %H:%M:%S")
          @from_datetime = Time.zone.parse(_from_datetime).utc
          _to_datetime = DateTime.parse(params[:end_date]).strftime("%Y-%m-%d %H:%M:%S")
          @to_datetime = Time.zone.parse(_to_datetime).utc
        end  

        @resources = Resource.active_only.by_unit(_unit_id).order('id').get_root_resources
        @resources = @resources.by_section(params[:section_id]) if params[:section_id].present?
        @resources = @resources.by_resource_type(params[:resource_type_id]) if params[:resource_type_id].present?        
        @resources = @resources.set_state(params[:resource_state_id]) if params[:resource_state_id].present?                
        @resources = @resources.by_date(params[:reservation_date]) if params[:reservation_date].present?      
        #@reservations = Reservation.by_date_range(params[:start_date].to_date - 1 , params[:end_date].to_date - 1).not_trash(0) if params[:start_date].present? && params[:end_date].present?
        #@reservations = Reservation.start_date(params[:start_date].to_date - 1).not_trash(0).by_slot(params[:slot_id]) if params[:start_date].present? && params[:slot_id].present?
        #_resource_ids = @reservations.map { |e| e.reservation_detail.map { |d| d.resource_id } } if @reservations.present?
        #@resources = @resources.set_id_not_in(_resource_ids) if _resource_ids.present?
        @resources_count = @resources.count
        @resources = @resources.page(params[:page]).per(_per) if params[:page].present?
        @extra = params[:resources].present? ? params[:resources].split(',') : Array.new
        rescue Exception => @error              
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception           
      end


      ### => API Documentation (APIPIE) for 'update' action
      api :PUT, '/api/v2/resources/:id', "Update resource status. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :resource_state_id, String, :required => true, :desc => "Filter by resource status ID"
      param :unit_id, String, :required => true, :desc => "Filter resources of an unit"
      param :user_id, String, :required => true, :desc => "User ID"
      def update
        ActiveRecord::Base.transaction do # Protective transaction block
          @status_log = Resource.update_resource_state(params[:resource_state_id],params[:unit_id],params[:id],params[:user_id],params[:device_id])
        end                
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception                       
      end

      ### => API Documentation (APIPIE) for 'swap_resource' action
      api :POST, '/api/v2/resources/swap_resource', "Swap resource orders. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :old_resource_id, String, :required => true, :desc => "Old Resource ID"
      param :new_resource_id, String, :required => true, :desc => "New Resource ID"
      param :unit_id, String, :required => true, :desc => "Unit ID"
      param :user_id, String, :required => true, :desc => "User ID"
      param :order_ids, String, :required => true, :desc => "Order IDs is JSON formats, which will be swapped to new table, [{'order_id':'1234'},{'order_id':'1235'},{'order_id':'1236'}]"
      def swap_resource
        ActiveRecord::Base.transaction do # Protective transaction block
          _order_ids = JSON.parse(params[:order_ids])
          _old_resource = Resource.find(params[:old_resource_id])
          _new_resource = Resource.find(params[:new_resource_id])
          @swap_status = Resource.swap_resource_orders _order_ids, _new_resource, _old_resource, params[:device_id], params[:user_id], params[:unit_id]
        end
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception      
      end

      def get_available_resource 
        _date = params[:reservation_date].present? ? params[:reservation_date] : Date.today
        @availablity = Availability.distinct_resource_by_date(_date)
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?  
      end

      api :GET, '/api/v2/resources/unique_identity_no', "Get Resource details"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unique_identity_no, String, :required => true, :desc => "unique_identity_no of the resource"
      def by_unique_identity_no
        @resource = Resource.find_by_unique_identity_no(params[:unique_identity_no])
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? 
      end

      api :GET, '/api/v2/resources/resource_pjp', "Get Pjp of Resource (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :user_id, String, :required => true, :desc => "id of the user whose pjp you want"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"
      
      def resource_pjp
        _per = params[:per] || 100
        @date_count = Time.days_in_month(Time.now.month, Time.now.year)
        if params[:page].present?
          _current_date = Date.today.beginning_of_month + ((params[:page].to_i - 1)* _per.to_i)
          _upto_date = _current_date + _per.to_i - 1
          _upto_date = Date.today.end_of_month if _upto_date > Date.today.end_of_month  
        else
          _current_date = Date.today.beginning_of_month
          _upto_date = Date.today.end_of_month
        end  
        @pjp_date = {}
        (_current_date.._upto_date).each do |t_date|
          arr = Array.new()
          #this block is active when the bit wise allocation configuration is enabled
          if AppConfiguration.get_config_value("bit_wise_resource_allocation") == "enabled"
            bit_allocations = UserBit.by_date(t_date).by_user(params[:user_id])
            bit_allocations.each do |user_bit|
              user_bit.bit.bit_resources.each do |bit_res|
                resources = build_resource_hash(bit_res.resource,t_date)
                arr.push resources
              end
            end
          #this block is active when bit wise allocation is disabled
          else
            resource_allocations = UserResource.by_date(t_date).by_user(params[:user_id])
            resource_allocations.each do |ra|
              resource = ra.resource 
              if resource.present? 
                resources = build_resource_hash(resource,t_date)
                arr.push resources
              end  
            end
          end  
          @pjp_date[t_date] = arr
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?
      end


      ### => API Documentatation (APIPIE) for 'resource_group_data' action
      api :GET, 'api/v2/resources/resource_group_data', "list of resource_group_data"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :resource_id, String, :required => true
      def resource_group_data
        @quarter = ((Time.now.month - 1) / 3) + 1
        @arr = [1]         
        rescue Exception => e
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end


      # call this method with resource object to  build resource allocation hash
      def build_resource_hash(resource,t_date)
        resource_target = resource.resource_targets.set_target_by(params[:user_id]).by_date(t_date)
        resources = {}
        resources["id"] = resource.id
        resources["bit_id"] = resource.bit_resources.present? ? resource.bit_resources.first.bit_id : nil
        resources["bit_name"] = resource.bit_resources.present? ? resource.bit_resources.first.bit.name : ""
        resources["name"] = resource.name
        resources["properties"] = resource.properties
        resources["unit_id"] = resource.unit_id
        resources["section_id"] = resource.section_id
        resources["printer_id"] = resource.printer_id
        resources["customer_id"] = resource.customer_id
        resources["unique_identity_no"] = resource.unique_identity_no
        resources["resource_type"] = resource.resource_type.name
        resources["target_type"] = resource_target.present? ? resource_target.last.target_type : ''
        resources["target_amount"] = resource_target.present? ? resource_target.last.target_amount : 0
        if resource.recorded_at.present?
          resources["recorded_at"] = resource.recorded_at.strftime("%Y-%m-%d %H:%M:%S")
        else
          resources["recorded_at"] = resource.created_at.strftime("%Y-%m-%d %H:%M:%S")
        end  
        if resource.customer_id.present?
          customer = Customer.find(resource.customer_id)
          resources["customer_name"] = customer.customer_profile.customer_name
          resources["latitude"] = customer.addresses.first.latitude
          resources["longitude"] = customer.addresses.first.longitude
          resources["delivery_address"] = customer.addresses.first.delivery_address
          resources["mobile_no"] = customer.mobile_no
          if customer.customer_state_id.present?
            resources["customer_state_id"] = customer.customer_state_id 
            resources["customer_state"] = customer.customer_state.name
          else
            resources["customer_state_id"] = customer.customer_state_id 
            resources["customer_state"] = ''
          end
        else
          resources["customer_name"] = resource.customer_id
          resources["latitude"] = resource.customer_id
          resources["longitude"] = resource.customer_id
          resources["delivery_address"] = resource.customer_id
          resources["mobile_no"] = resource.customer_id
          resources["customer_state_id"] = resource.customer_id
          resources["customer_state"] = ''
        end  
        return resources
      end
    end
  end
end