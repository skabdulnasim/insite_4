module Api
	module V2
		class WarehousesController<ApplicationController
			# put function for warehouse
			api :POST, '/api/v2/warehouses/put_product', "To put product into warehouse"
			param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			param :bin_products,Hash,:required=>true, :desc=> <<-EOS

          ==== A sample parameter value is given below
            {
              "bin_unique_id":"005003006",
              "sku":"0000073926",
              "product_quantity":10
            }
        EOS
      	formats ['json']
			def put_product
				_allocated_quantity = 0
				_stock_credit = Stock.where("sku=?",params[:bin_products][:sku]).pluck(:stock_credit).first
				_bins = BinProduct.where("sku = ?",params[:bin_products][:sku]).select("product_quantity")
				
				# calculate the totoal allocated quantity in bins of a particular sku 
				if _bins.present?
					_bins.each do |product_quantity|
						_allocated_quantity += product_quantity.product_quantity
					end
				end
				bin = Bin.where("bin_unique_id=?",params[:bin_products][:bin_unique_id]).first
				if bin.status == "available"
					raise "No stock remaining" if _allocated_quantity == _stock_credit
					
					## determine the newly allocatable quantity of the product into bin
					_allocatable_quantity = _allocated_quantity+params[:bin_products][:product_quantity].to_f > _stock_credit ? _stock_credit-_allocated_quantity : params[:bin_products][:product_quantity]
					stock = Stock.where("sku= ? AND stock_transaction_type= ?",params[:bin_products][:sku],"StockPurchase").select("product_id").first
					@bin_product = bin.build_bin_product(:bin_unique_id=>params[:bin_products][:bin_unique_id],:product_id=>stock.product_id,:sku=>params[:bin_products][:sku],:product_quantity=>_allocatable_quantity)
					if @bin_product.save
						bin.update_attribute("status","allocated")
					else
						raise "unable to save bin_product"
					end
				else
					raise "Bin is not available"
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			############### pick function for warehouse####################
			api :POST, '/api/v2/warehouses/pick_product', "To pick product from warehouse"
			param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :bin_unique_id, String, :required => true, :desc => "Unique Id of the bin from where you want to pick the product"
      param :product_quantity, String, :required => true, :desc => "Quantity of the product to be picked from the bin"
			def pick_product
				puts params
				@bin  = Bin.where("bin_unique_id=?",params[:bin_unique_id]).first
				if @bin.status == "available"
					raise "this is an empty bin"
				else
					if @bin.bin_product.product_quantity>=params[:product_quantity].to_i
						@bin.bin_product.update_attribute("product_quantity",@bin.bin_product.product_quantity-params[:product_quantity].to_i)
						if @bin.bin_product.product_quantity==0
							@bin.update_attribute("status","available")
							@bin.bin_product.destroy
						end
					else
						raise "Insufficient Product in bin"
					end
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			############# fetch all bin's ids for a product SKU/ID ###################

			api :GET, '/api/v2/warehouses/product_bins', "To Search product in warehouse"
			param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :product_id, String, :required => false, :desc => "Product id(pass this parameter alternatively with 'sku' param)"
      param :sku, String, :required => false, :desc => "Product SKU (pass this parameter alternatively with 'product_id' param)"

			def product_bins
				@bins = BinProduct.where("sku = ?",params[:sku]).select("bin_unique_id,product_quantity,product_id") if params[:sku].present?
				@bins = BinProduct.where("product_id = ?",params[:product_id]).select("bin_unique_id,product_quantity,product_id") if params[:product_id].present?
				if params[:sku].present?
					@stock_received = Stock.where("sku=?",params[:sku]).pluck(:stock_credit).first
					if !@stock_received
						raise "SKU not found"
					end
				end
				if params[:product_id].present?
					if !@bins.present?
						raise "Product not found"
					end
				end
				# @bins.each do |bin|
				# 	puts bin.inspect
				# end
				# if !@bins.present?
				# 	raise "no bin found"
				# end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			#fetch the product quantity in a perticular bin
			api :GET, '/api/v2/warehouses/bin_product_quantity', "To get the product details in a bin"
			param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :bin_unique_id, String, :required => true, :desc => "Unique ID of the bin"
			def bin_product_quantity
				puts params[:bin_unique_id]
				@bin_product = BinProduct.where("bin_unique_id=?",params[:bin_unique_id]).select("product_id,product_quantity")
				if !@bin_product.present?
					raise "no product found"
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
			private
		end
	end
end