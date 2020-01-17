module Api
  module V2
    class StockTransfersController < ApplicationController

      before_filter :set_timerange, only: [:index]

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/stock_transfers', "Get List of all stock transfer."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :store_id, String, :required => true, :desc => "If this parameter is available, then you will get all stock transfers of corresponding store."
      param :transfer_type, String, :required => true, :desc => "transfer_type: (credit, debit)"
      param :status, Array, :desc => "status: (20,30) for not deliver, (10) for pickup pending, (100) for delivered"
      param :from_date, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`from_date` parameter is dependent on `to_date` parameter"
      param :to_date, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`to_date` parameter is dependent on `from_date` parameter"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      formats ['json']

      def index
        _per = params[:count] || 20
        store = Store.find(params[:store_id])
        @stock_transfers = store.stock_credit_transfers.desc_order if params['transfer_type'].present? && params['transfer_type']=='credit'
        @stock_transfers = store.stock_debit_transfers.desc_order if params['transfer_type'].present? && params['transfer_type']=='debit'
        @stock_transfers = @stock_transfers.set_status_in(params['status']) if params['status'].present?
        @stock_transfers = @stock_transfers.by_date_range(@from_datetime,@to_datetime) if params[:from_date].present?
        @stock_transfers_count = @stock_transfers.count
        @stock_transfers = @stock_transfers.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?
      end

      def create
        ActiveRecord::Base.transaction do
          @stock_transfer = StockTransfer.new(params[:stock_transfer])
          if @stock_transfer.save
            if params[:stock_transfer][:store_requisition_log_id].present?
              @stock_transfer.stock_transfer_meta.each do |stock_meta|
                StoreRequisitionLog.update_log(stock_meta.product_id,params[:stock_transfer][:store_requisition_log_id],stock_meta.quantity_transfered)
              end
            end
            @stock_transfer.reload
          else
            @validation_errors = error_messages_for(@stock_transfer)
          end
        end  
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? 
      end

      ### => API Documentation (APIPIE) for 'index' action
      # api :PUT, '/api/v2/stock_transfers/:id', "Recive transfered stock."
      # error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      # param :received_stocks, Hash, :desc => "Parameter to provide the transfered stocks product with quantity."
      # param :user_id, String, :desc => "Parameter to provide stock receiver id."
      # formats ['json']

      def update
        ActiveRecord::Base.transaction do
          @stock_transfer = StockTransfer.find(params[:id])
          if @stock_transfer.status == '100'
            @stock_transfer.reload
            @validation_errors = "Product already received."
          else 
            if @stock_transfer.update_attributes(params[:stock_transfer])
              @stock_transfer.reload
            else
              @validation_errors = error_messages_for(@stock_transfer)
            end
          end  
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?       
      end

      def get_est_price
        @tax_groups = TaxGroup.all
        @store_id = params[:store_id]
        @product_details = params[:product_details]
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?
      end
    end
  end
end