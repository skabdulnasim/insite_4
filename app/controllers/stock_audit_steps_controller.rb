class StockAuditStepsController < ApplicationController
	include Wicked::Wizard
	steps :confirmation
	before_filter :get_store_details

	def show
		_stock_audit = StockAudit.find(params[:stock_audit_id])
		@stock_audit_meta = _stock_audit.stock_audit_metas
		@business_type = _stock_audit.business_type
		render_wizard
	end
	def update
		begin 
			_store = Store.find(params[:store_id])
			_stock_audit = StockAudit.find(params[:stock_audit_id])
			params[:audit_meta_ids].each do |meta_id|
				_audit_meta = StockAuditMeta.find(meta_id)
				_delta_stock  = _audit_meta.current_stock.to_f - params["quantity_#{meta_id}"].to_f
				updatable_atrributes = {:counted_stock=>params["quantity_#{meta_id}"],:delta_stock=>_delta_stock,:remarks=>params["remarks_#{meta_id}"],:reason_code=>params["reason_for_#{meta_id}"]}
				_audit_meta.update_attributes(updatable_atrributes)
			end
		rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to store_stock_audit_steps_path(_store,_stock_audit), alert: e.message.to_s
    else
      redirect_to store_path(_store), notice: "Stock audit was successfully submitted for approval."  
		end
	end	

	private

	def get_store_details
		@store = Store.find(params[:store_id])
	end
end
