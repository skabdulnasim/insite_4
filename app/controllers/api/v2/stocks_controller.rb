module Api
  module V2
    class StocksController < ApplicationController
      before_filter :authenticate_user_with_token!, only: [:index]

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/stocks', "Get stock of items of a store. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :store_id, String, :required => true, :desc => "Filter stocks of a store"
      param :product_id, String, :required => false, :desc => "Filter stocks of a product"
      param :product_ids, String, :required => false, :desc => "Filter stocks by an array of product ids"
      param :from_date, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`from_date` parameter is dependent on `to_date` parameter"
      param :to_date, String, :required => false, :desc => "This parameter can be used to get results between two dates.", :meta => "`to_date` parameter is dependent on `from_date` parameter"      
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"

      ### => 'index' API Defination      
      def index
        _per = params[:per] || 100
        @stocks = Stock.available.by_store(params[:store_id])
        @stocks = @stocks.page(params[:page]).per(_per) if params[:page].present?
        @stocks = @stocks.by_date_range(params[:from_date], params[:to_date]) if params[:from_date].present? and params[:to_date].present?
        @stocks = @stocks.by_products(params[:product_ids]) if params[:product_ids].present?
        @stocks = @stocks.by_product(params[:product_id]) if params[:product_id].present?
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception        
      end

      ### => API Documentation (APIPIE) for 'get_all_product_stocks' action
      api :GET, '/api/v2/stocks/get_all_product_stocks', "Get stock of items of a store."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :business_type, String, :required => false, :desc => "Product filter by business_type"
      param :store_id, String, :required => true, :desc => "Filter stocks of a store"
      param :category_id, String, :required => false, :desc => "Filter product by category_id"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"
      param :filter_string, String, :required => false, :desc => "fiter by product name"
      def get_all_product_stocks
        @store_id = params[:store_id]
        _per = params[:per] || 100
        _per = params[:per] || 20 if params[:business_type].present? && params[:business_type] != 'by_catalog'
        @stocks = Product.order('name asc')
        @stocks = @stocks.by_business_type(params[:business_type]) if params[:business_type].present?
        @stocks = @stocks.by_category_id(params[:category_id]) if params[:category_id].present?
        @stocks = @stocks.filter_by_string(params[:filter_string]) if params[:filter_string].present?
        @stocks_count = @stocks.count
        if !params[:business_type].present? || params[:business_type] == 'by_catalog'
        # if !params[:business_type].present?
        #   params[:business_type] = 'by_catalog'
          _product_ids = @stocks.pluck(:id)
          if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
            @stocks = Stock.set_store(@store_id).select("product_id,sku,expiry_date,batch_no,sum(available_stock) as total_available_stock").group("product_id,sku,expiry_date,batch_no").available.by_products(_product_ids)
            @stocks_count = 0
            @stocks.map { |e| @stocks_count+=1 }
          end
        end
        @stocks = @stocks.page(params[:page]).per(_per) if params[:page].present?
        @paginated_stocks_count = 0
        @stocks.map { |e| @paginated_stocks_count+=1 }
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception  
      end

      ### => API Documentation (APIPIE) for 'get_all_product_stocks' action
      api :GET, '/api/v2/stocks/get_business_type', "Get stock of items of a store."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      def get_business_type
        @business_types = Product::BUSINESS_TYPE
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :GET, '/api/v2/stocks/in_out_stock', "Get in out stocks of a store"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :store_id, String, :required => true, :desc => "id of the store"
      param :stock_filter, String, :required => false, :desc => "stock status 1 for instock 2 for out stock"
      param :business_type, String, :required => false, :desc => "Product filter by business_type"
      param :category_id, String, :required => false, :desc => "Filter product by category_id"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"
      param :filter_string, String, :required => false, :desc => "fiter by product name"
      def in_out_stock
        @store_id = params[:store_id]
        _per = params[:per] || 100
        @stocks = Product.order('name asc')
        @stocks = @stocks.by_business_type(params[:business_type]) if params[:business_type].present?
        @stocks = @stocks.check_stock_status(@store_id,params[:stock_filter],'') if params[:stock_filter]
        @stocks = @stocks.by_category_id(params[:category_id]) if params[:category_id].present?
        @stocks = @stocks.filter_by_string(params[:filter_string]) if params[:filter_string].present?
        @stocks_count = @stocks.count

        if !params[:business_type].present? || params[:business_type] == 'by_catalog'
          _product_ids = @stocks.pluck(:id)
          if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
            @stocks = Stock.set_store(@store_id).select("product_id,sku,expiry_date,batch_no,sum(available_stock) as total_available_stock").group("product_id,sku,expiry_date,batch_no").available.by_products(_product_ids)
            @stocks_count = 0
            @stocks.map { |e| @stocks_count+=1 }
          end
        end

        @stocks = @stocks.page(params[:page]).per(_per) if params[:page].present?
        @paginated_stocks_count = 0
        @stocks.map { |e| @paginated_stocks_count+=1 }
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception 
      end
    end
  end
end