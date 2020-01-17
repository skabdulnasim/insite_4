json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
if @error.present?
  json.data Array.new
else
  json.data @prduct_quantity do |pq|
    menu_product = MenuProduct.find_by_id(pq.menu_product_id)
    if menu_product.present?
	    json.qtu pq.total_qty
	    json.menu_product_id pq.menu_product_id
	    json.product_name pq.product_name
	    json.product_id pq.product_id
	    json.date pq.date
	    json.store_id menu_product.store.id
	  end
  end
end