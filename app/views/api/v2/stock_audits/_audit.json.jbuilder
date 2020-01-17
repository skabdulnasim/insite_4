json.extract! stock_audit, :id, :audit_done_by, :audit_reviewed_by, :status, :created_at, :updated_at
json.audit_done_by_user full_name(stock_audit.audit_done_by) if stock_audit.audit_done_by.present?
json.audit_status audit_status(stock_audit.status)

json.audit_details stock_audit.stock_audit_metas do |audit_meta|
	json.extract! audit_meta, :id, :audit_options, :counted_stock, :current_stock, :delta_stock, :product_id, :remarks, :stock_added, :stock_audit_id, :stock_consumed
	json.current_stock_at_review get_product_current_stock(stock_audit.store_id, audit_meta.product_id) 
	json.product_name audit_meta.product.name
	json.product_basic_unit audit_meta.product.basic_unit
	json.currency currency
end

