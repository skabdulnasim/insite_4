module Api
  module V2
    class StockPredictionsController < ApplicationController

        ### => API Documentation (APIPIE) for 'index' action
        api :GET, '/api/v2/stock_predictions/get_stocks_transfer_details', "Get List of all stock transfer."
        param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
        param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
        param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
        param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
        param :from_date, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`from_date` parameter is dependent on `to_date` parameter"
        param :to_date, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`to_date` parameter is dependent on `from_date` parameter"
        error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
        formats ['json']

        def get_stocks_transfer_details
          _per = params[:count] || 20
          @stocks = Stock.set_transaction_type(['StockTransfer']).by_date_range(params[:from_date],params[:to_date])
          @stocks_count = @stocks.count
          @stocks = @stocks.page(params[:page]).per(_per) if params[:page].present?
          rescue Exception => @error
          @log = Rscratch::Exception.log(@error,request) if @error.present?
        end

        def get_product_composition
          @products = ProductComposition.uniq.pluck(:product_id)
        end

    end
  end
end