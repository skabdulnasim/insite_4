module Api
	module V2
		class CustomerProductWishlistsController < ApplicationController

			### => API Documentation (APIPIE) for 'index' action
			api :GET, '/api/v2/customer_product_wishlists', "List of all colors."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :customer_id, String, :required => true, :desc => "Id of customer, whose wishlist you want"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"
      ### => 'index' API Defination
			def index
				@wishlists = CustomerProductWishlist.by_customer(params[:customer_id])
				@total_count = @wishlists.count
				_per = params[:per] || 20
				@wishlist = @wishlists.page(params[:page]).per(_per) if params[:page].present?
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/customer_product_wishlists', "Customer wishlist create."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."      
      
      param :customer_product_wishlists, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
        {
          "customer_id":"1"
          "menu_product_id":"2"
        }
      EOS
      formats ['json']

      def create
        ActiveRecord::Base.transaction do
          @wishlist = CustomerProductWishlist.new(params[:customer_product_wishlists])
          if @wishlist.save
            @wishlist.reload
          else
            @validation_errors = error_messages_for(@wishlist)
          end
        end
        #@resources = params[:resources].present? ? params[:resources].split(',') : []
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception 
      end

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/customer_product_wishlists/remove_product', "Remove product from customer wish list."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the order."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."      
      param :id, String, :required => true, :desc => "id of wishlist"

      def remove_product
        ActiveRecord::Base.transaction do
          @wishlist = CustomerProductWishlist.find(params[:id])
          @wishlist.destroy if @wishlist.present?
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

		end
	end
end