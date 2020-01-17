# Adding product basic info
json.extract! menu_product, :id, :menu_category_id, :product_id, :mode, :sell_price, :sell_price_without_tax, :sort_id, :store_id, :updated_at, :is_buffet_product, :isdefault, :stock_status, :variable_id, :combo_id, :tax_group_id, :procured_price, :bill_destination_id, :stock_qty, :delivery_mode, :max_order_qty, :commission_capping, :commission_capping_type, :is_unit_currency, :unit_currency_price
json.unit_currency menu_product.menu_card.unit.unit_currency
json.kot_print menu_product.sort.kot_print
product_lots = menu_product.product.lots.by_store(menu_product.store_id).active_mode.active.not_expiry
if params[:customer_id].present?
	json.has_wishlist CustomerProductWishlist.exists?(customer_id: params[:customer_id],product_id: menu_product.product_id)
end
if @resources.include? 'lots'
	# if menu_product.lots.active_mode.active.not_expiry.present?
	if product_lots.present?
		json.sell_price product_lots.first.sell_price
		json.sell_price_without_tax product_lots.first.sell_price_without_tax
		json.mrp product_lots.first.mrp
		json.product_sku product_lots.first.sku
		json.procured_price product_lots.first.procured_price
	else
		json.sell_price menu_product.sell_price
		json.sell_price_without_tax menu_product.sell_price_without_tax
		json.mrp 0
		json.product_sku menu_product.product.sku
		json.procured_price menu_product.procured_price
	end
# elsif menu_product.lots.present?
elsif menu_product.product.lots.by_store(menu_product.store_id).present?
	mp_lots = menu_product.product.lots.by_store(menu_product.store_id)
	json.sell_price mp_lots.first.sell_price
	json.sell_price_without_tax mp_lots.first.sell_price_without_tax
	json.mrp mp_lots.first.mrp
	json.product_sku mp_lots.first.sku
	json.procured_price mp_lots.first.procured_price	
else
	json.sell_price menu_product.sell_price
	json.sell_price_without_tax menu_product.sell_price_without_tax
	json.mrp 0
	json.product_sku menu_product.product.sku
	json.procured_price menu_product.procured_price
end	
json.menu_category_name menu_product.menu_category.name
#json.sort_name menu_product.sort.name
json.product_name menu_product.product.name
json.local_name menu_product.product.local_name 
json.product_hsn_code menu_product.product.hsn_code
json.product_basic_unit menu_product.product.basic_unit
_image_size = "thumb"
_image_size = params[:image_size] if params[:image_size].present?
_image = menu_product.product.product_images.first
_image_url = _image.present? ? "#{_image.image.url(:"#{_image_size}")}" : ""
if @resources.include? 'product_images'
	json.product_images menu_product.product.product_images do |_product_image|
		json.product_image _product_image.image_file_name
		json.product_image_url "#{_product_image.image.url(:"#{_image_size}")}"
	end
else
	json.product_image _image.present? ? "#{_image.image_file_name}" : ""
	json.product_image_url _image_url
end
json.product_type menu_product.product.product_type

json.product_callorie menu_product.product.callorie
json.product_description menu_product.product.short_description
if menu_product.product.product_religion.present?
	json.product_religion menu_product.product.product_religion.name 
else
	json.product_religion menu_product.product.product_religion
end
# Adding product tax info
json.tax_group_name menu_product.tax_group.name
json.tax_group_amount menu_product.tax_group.total_amnt
json.tax_classes menu_product.tax_group.tax_classes, :id, :name, :ammount, :tax_type, :lower_limit, :upper_limit, :amount_type, :operation_type
json.allergies menu_product.product.allergy_products do |ap|
	json.name ap.allergy.name
end
# Adding product combinations and it's rules
json.combinations menu_product.menu_product_combinations do |mpc|
  json.extract! mpc, :id, :ammount, :menu_product_id, :product_id, :combination_type_id, :combinations_rule_id, :price, :product_unit_id
  json.product_name mpc.product.name
  json.product_unit mpc.product_unit.short_name if mpc.product_unit_id.present?
end

# Adding product tags
json.product_tags menu_product.product.tags do |tag|
  json.extract! tag, :id, :name, :status, :tag_type, :color
  _image_size = "thumb"
	_image_url = tag.icon.present? ? "#{tag.icon.url(:"#{_image_size}")}" : ""
	json.tag_icon tag.icon.present? ? "#{tag.icon_file_name}" : ""
	json.product_image_url _image_url
end

if @resources.include? 'stocks'
	json.stocks Stock.by_expiry_date(menu_product.product_id, menu_product.store_id) do |stock|
		json.stock_id stock.id	
	  json.product_id menu_product.product_id
	  json.stocks stock.total_stock
	  json.basic_unit menu_product.product.basic_unit
	  json.expiry_date stock.expiry_date
	  json.stock_sku stock.sku
	end
end	

if @resources.include? 'lots'
	# json.lots menu_product.lots.active_mode.active.not_expiry do |lot|
	json.lots product_lots do |lot|
		json.extract! lot, :id, :menu_product_id, :mode, :sell_price, :sell_price_without_tax, :sku, :stock_qty, :tax_group_id, :product_id, :expiry_date, :stock_id, :procured_price, :mrp, :menu_card_id, :color_name, :size_name, :model, :color_id, :size_id, :lot_desc, :product_basic_unit, :store_id
		json.basic_unit lot.product.basic_unit
		_product_size = ProductSize.find_by_product_id_and_size_id(lot.product_id,lot.size_id) if lot.size_id.present?
		if _product_size.present?
			json.product_size_images _product_size.product_size_images do |psi|
				_image_size = "thumb"
				_image = psi
				_image_url = _image.present? ? "#{_image.image.url(:"#{_image_size}")}" : ""
				json.product_image _image.present? ? "#{_image.image_file_name}" : ""
				json.product_image_url _image_url
			end
		end
	end
end

json.combination_rules menu_product.combinations_rules, :id, :name, :max_qty, :min_qty
json.combination_types menu_product.combination_types, :id, :name
# Adding product variants
json.variants menu_product.variants, partial: 'api/v2/menu_cards/menu_product', as: :menu_product
# Adding product combos
json.combos menu_product.combos, partial: 'api/v2/menu_cards/menu_product', as: :menu_product
json.combo_items menu_product.combo_items, partial: 'api/v2/menu_cards/combo_items', as: :combo_item
