module Api
  module V2
    class ProductsController < ApplicationController
      #load_and_authorize_resource

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/products', "List of all products."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :category_id, String, :required => false, :desc => "Filter product by category_id"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"
      ### => 'index' API Defination
      def index
        @root_categorys = Category.get_root_categories
        _per = params[:per] || 100
        @products = Product.order('name asc')
        @products = @products.by_category_id(params[:category_id]) if params[:category_id].present?
        @product_count = @products.count
        @products = @products.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'show' action
      api :GET, '/api/v2/products/:id', "API to fetch a order."
      param :email, String, :required => false, :desc => "Email ID of user, who is show the order."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      def show
        @product = Product.find(params[:id])
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'get_colors_sizes' action
      api :GET, '/api/v2/products/get_colors_sizes', "Color and size for a specific product"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :product_id, String, :required => true, :desc => "Filter color and size for this product_id"
      def get_colors_sizes
        @product = Product.find(params[:product_id])
        @product_units = ProductUnit.order("created_at")
        @product_units = @product_units.by_basic_unit(params[:product_basic_unit_id]) if params[:product_basic_unit_id].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
    end
  end
end
