module Api
	module V2
		class OrderDetailsController < ApplicationController

			def update
				begin
					ActiveRecord::Base.transaction do
						@order_detail = OrderDetail.find(params[:id])
						@order_detail.update_attributes(params[:order_detail])
					end
				rescue Exception => e
				@log = Rscratch::Exception.log(@error,request) if @error.present?
				end
			end

		end
	end
end