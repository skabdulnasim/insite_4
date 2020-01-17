module Api
  module V2
    class ReturnItemsController < ApplicationController

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/return_items', "List of all return items."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :delivery_boy_id, String, :required => true, :desc => "Id of the assigned delivery boy for filtering return items."
      param :unit_id, String, :required => false, :desc => "Filter return items of an unit."
      param :store_id, String, :required => false, :desc => "Filter return items of a store."
      param :order_status_id, String, :required => false, :desc => "Filter return items by return order status."
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"

    	def index
        ActiveRecord::Base.transaction do
      		@return_items = ReturnItem.by_delivery_boy(params[:delivery_boy_id])
      		@return_items = @return_items.unit_return(params[:unit_id]) if params[:unit_id].present?
          @return_items = @return_items.by_store(params[:store_id]) if params[:store_id].present?
    		  @return_items = @return_items.by_return_status(params[:order_status_id]) if params[:order_status_id].present?
          @return_items_count = @return_items.count
          _per = params[:per] || 20
          @return_items = @return_items.page(params[:page]).per(_per) if params[:page].present?
        end
    		rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
    	end

      ### => API Documentation (APIPIE) for 'update' action
      api :PUT, '/api/v2/return_items/:id', "Edit a return item after pickep up."
      param :email, String, :required => true, :desc => "Email ID of user."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :return_status_id, String, :required => true, :desc => "Status of the return item."
      param :picked_by, String, :required => true, :desc => "Id of the delivery boy, who picked up the return item"

      def update
        ActiveRecord::Base.transaction do
          @return_item = ReturnItem.find(params[:id])
          if @return_item.present?
            @return_item.update_column(:return_status_id, params[:return_status_id])
            @return_item.update_column(:picked_by, params[:picked_by])    
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception 
      end

   	end
  end
end