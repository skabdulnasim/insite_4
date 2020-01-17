module Api
	module V2
		class PurchaseOrdersController < ApplicationController

			### => API Documentation (APIPIE) for 'index' action
      # api :GET, '/api/v2/purchase_orders', "Get List of all purchase orders."
      # error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      # param :store_id, String, :desc => "If this parameter is available, then you will get all purchase orders of corresponding store."
      # param :type, String, :desc => "If this parameter is available with value 'pending', then you will get pending purchase orders of corresponding store."
      # formats ['json']

			def index
				store = Store.find(params[:store_id])
				@purchase_orders = PurchaseOrder.where(store_id: store.id).valid_till
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			def create
				puts params
				begin
					ActiveRecord::Base.transaction do
						@purchase_order = PurchaseOrder.new(params[:purchase_order])
						@purchase_order[:recurring]	=	0
						@purchase_order[:purchase_order_code]="PO"+(Time.now.to_i).to_s+"#{rand(1000)}"
	          unless @purchase_order.new_record? and @purchase_order.save
	            @validation_errors = error_messages_for(@purchase_order)
	          end
					end
				rescue Exception => e
					@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
				end
			end

			def show
				@purchase_order = PurchaseOrder.find(params[:id])
				@stock_purchases = @purchase_order.stock_purchases.received
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			def approval_show
				@purchase_order = PurchaseOrder.find(params[:id])
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

		end
	end
end