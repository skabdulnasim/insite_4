json.extract! combo_item, :id, :color_id, :item_id, :menu_product_id, :mode, :sell_price, :sell_price_without_tax, :size_id, :tax_group_id, :quantity
json.product_name combo_item.product.name
json.product_basic_unit combo_item.product.basic_unit
_image_size = "thumb"
_image_size = params[:image_size] if params[:image_size].present?
_image = combo_item.product.product_images.first
_image_url = _image.present? ? "#{_image.image.url(:"#{_image_size}")}" : ""
if @resources.include? 'product_images'
	json.product_images combo_item.product.product_images do |_product_image|
		json.product_image _product_image.image_file_name
		json.product_image_url "#{_product_image.image.url(:"#{_image_size}")}"
	end
else
	json.product_image _image.present? ? "#{_image.image_file_name}" : ""
	json.product_image_url _image_url
end