module Api
	module V2
		class StockPurchasesController < ApplicationController

			before_filter :set_timerange, only: [:index]
			
      ### => API Documentation (APIPIE) for 'index' action
      # api :GET, '/api/v2/stock_purchases', "Get List of pending purchase orders."
      # error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      # param :store_id, String, :desc => "If this parameter is available, then you will get pending purchase orders of corresponding store."
      # formats ['json']

			def index
				store = Store.find(params[:store_id])
				@purchase_orders = store.stock_purchases.desc_order
				@purchase_orders = @purchase_orders.by_status(params[:status]) if params[:status].present?
				@purchase_orders = @purchase_orders.date_range(@from_datetime,@to_datetime) if params[:from_date].present? && params[:to_date].present?
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

      ### => API Documentation (APIPIE) for 'Update' action
      # api :GET, '/api/v2/stock_purchases/:id', "Receive existing purchase orders."
      # error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      # param :products, Hash, :desc => "Parameters to provide the purchase orders details with product"
      # param :invoice_image, Attachment, :desc => "Parameters to upload invoice image"
      # formats ['json']

			def update
				begin
					products = params[:products]
					@stock_purchase = StockPurchase.find(params[:id])
					raise 'Products in this purchase order already received.' if @stock_purchase.status == "2"
					# raise "Attachment not found" unless params[:invoice_image].present?
					ActiveRecord::Base.transaction do # Protective transaction block
						products.each do |rs|
							_recvd_stock = Stock.save_stock(rs['product_id'],@stock_purchase.store_id,rs['price'],rs['recv_stock'],@stock_purchase.id,'stock_purchase',rs['recv_stock'],0,rs['expiry_date'],nil,nil,nil,rs['size'],rs['color'])
							if AppConfiguration.get_config_value('uniqe_sku_for_stock') == 'enabled'
		            sku = rs["Sku"].present? ? rs["Sku"] : format('%08d', _recvd_stock.id)
		          else    
		            sku = rs["Sku"].present? ? rs["Sku"] : format('%08d', rs['product_id']) 
		          end  
          		_recvd_stock.update_column(:sku, sku)
							StockPrice.add_stock_price(_recvd_stock.id, rs["lending_price"], rs["mrp"], rs['product_id'], rs["price"], nil, 0, rs["price"], nil,0,rs['mrp'])
							if AppConfiguration.get_config_value('retail_menu') == 'enabled'
                menu_cards = MenuCard.set_unit(@stock_purchase.store.unit_id).active
                menu_cards.each do |mc|
                  if MenuProduct.by_menu_card(mc.id).set_product(rs['product_id']).present?
                    mp = MenuProduct.by_menu_card(mc.id).set_product(rs['product_id']).first
                    _total_amnt = 0
                    mp.tax_group.tax_classes.each do |tc|
							        if tc.tax_type == 'variable'
							          if ((tc.lower_limit + (tc.lower_limit * tc.ammount)/100)..(tc.upper_limit + (tc.upper_limit * tc.ammount)/100)).include?(rs['mrp'].to_f)
							            _total_amnt = _total_amnt + tc[:ammount].to_f
							          end 
							        end
							      end
							      sell_price_without_tax = 0
							      sell_price_without_tax = (rs['mrp'].to_f * 100)/(_total_amnt.to_f + 100)
                    lot = Lot.new
                    lot.menu_product_id = mp.id
                    lot.mode = 0
                    lot.sell_price_without_tax = sell_price_without_tax
                    lot.sku = _recvd_stock.sku
                    lot.stock_qty = rs['recv_stock']
                    lot.product_id = rs['product_id']
                    lot.expiry_date = _recvd_stock.expiry_date
                    lot.stock_id = _recvd_stock.id
                    lot.procured_price = rs["lending_price"]
                    lot.mrp = rs['mrp']
                    lot.menu_card_id = mc.id
                    lot.save
                  end 
                end
              end 
						end
						@stock_purchase.update_attribute(:status, "2")
						@stock_purchase.update_attribute(:attachment, params[:invoice_image])
					end
				end
				rescue Exception => e
				@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			def get_payment_details
				@stock_purchase = StockPurchase.find(params[:id])
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			def generate_stock_receive_row
				@product = Product.find_by_name(params[:product_name])
				@retail_menu_conf = AppConfiguration.get_config_value('retail_menu')
				@perc_on_landing_conf = AppConfiguration.get_config_value('Percentage_applied_on_lending_price')
				@auto_generate_sku_conf = AppConfiguration.get_config_value('auto_generate_sku')
				@stock_expiry_date = AppConfiguration.get_config_value('stock_expiry_date')
				@input_tax_config = AppConfiguration.get_config_value('stock_input_tax')
				@product_sku = @product.properties.find_by_label("SKU").present? ? @product.properties.find_by_label("SKU").value : ''
				@percentages = Percentage.all
				@pom_id = params[:pom_id]
				_pom = PurchaseOrderMetum.find(@pom_id)
      	@product_unit_name = _pom.product_unit.present? ? _pom.product_unit.short_name : _pom.product.basic_unit
			end

		end
	end
end