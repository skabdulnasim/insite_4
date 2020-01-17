module Api
	module V2
		class StockAuditsController < ApplicationController
			def index
				store = Store.find(params[:store_id])
				@user = User.find(params[:user_id]) if params[:user_id].present?
				@stock_audits = store.stock_audits
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			def update
				begin
				  ActiveRecord::Base.transaction do # Protective transaction block
						@stock_audit = StockAudit.find(params[:id])
						_status = params[:status]
						products = params[:product_data]
						StockAudit.approve_audit(_status,@stock_audit,products)
						@stock_audit.update_attributes(:status => _status, :audit_reviewed_by => params[:user_id])
					end #End of transaction block
				rescue Exception => e
				@log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
				end    
			end

		end
	end
end