module Api
  module V2
    class TablesController < ApplicationController 
      
      before_filter :authenticate_user_with_token!, except: [:index]
      
      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/tables', "List of all tables."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "Filter tables of an unit"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"      
      param :section_id, String, :required => false, :desc => "Filter bu section ID"
      param :table_state_id, String, :required => false, :desc => "Filter by table status ID"
      
      def index
        _per = params[:count] || 20
        _unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
        @tables = Table.by_unit_id(_unit_id).order('id').enabled.non_trashed
        @tables = @tables.page(params[:page]).per(_per) if params[:page].present?
        @tables = @tables.set_section(params[:section_id]) if params[:section_id].present?
        @tables = @tables.set_state(params[:table_state_id]) if params[:table_state_id].present?     
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception           
      end
      
      ### => API Documentation (APIPIE) for 'update' action
      api :PUT, '/api/v2/tables/:id', "Update table status. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :table_state_id, String, :required => true, :desc => "Filter by table status ID"
      param :unit_id, String, :required => true, :desc => "Filter tables of an unit"
      param :user_id, String, :required => true, :desc => "User ID"
      def update
        ActiveRecord::Base.transaction do # Protective transaction block
          @status_log = Table.update_table_state(params[:table_state_id],params[:unit_id],params[:id],params[:user_id],params[:device_id])
        end                
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception                       
      end

      ### => API Documentation (APIPIE) for 'swap_table' action
      api :POST, '/api/v2/tables/swap_table', "Swap table orders. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :old_table_id, String, :required => true, :desc => "Old Table ID"
      param :new_table_id, String, :required => true, :desc => "New Table ID"
      param :unit_id, String, :required => true, :desc => "Unit ID"
      param :user_id, String, :required => true, :desc => "User ID"
      param :order_ids, String, :required => true, :desc => "Order IDs is JSON formats, which will be swapped to new table, [{'order_id':'1234'},{'order_id':'1235'},{'order_id':'1236'}]"
      def swap_table
        ActiveRecord::Base.transaction do # Protective transaction block
          _order_ids = JSON.parse(params[:order_ids])
          _old_table = Table.find(params[:old_table_id])
          _new_table = Table.find(params[:new_table_id])
          @swap_status = Table.swap_table_orders _order_ids, _new_table, _old_table, params[:device_id], params[:user_id], params[:unit_id]
        end
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception      
      end

    end
  end
end
