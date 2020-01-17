module Api
	module V2
		class OffersController < ApplicationController
			def index
				@offers = Advertisement.all
			end
			def get_offers
				offers = Advertisement.find(params[:id])
				puts offers.inspect
				if offers.present?
					@menu_products = MenuProduct.where("menu_card_id=?",offers.menu_card_id).select("DISTINCT(product_id)")
					puts "distnct lenght = #{@menu_products.count}"
					if @menu_products.present?
						@menu_products.each do |menu_product|
							puts menu_product.product.inspect
						end
					else
						puts "product not  found"
					end
				else
				end
				rescue Exception => @error
        		@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception	
			end
		end
	end
end