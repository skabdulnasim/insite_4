json.extract! wishlist, :id, :customer_id, :menu_card_id, :menu_product_id, :product_id, :mode
json.created_at wishlist.created_at.strftime("%d-%m-%Y, %I:%M %p")
json.menu_category_name wishlist.menu_product.menu_category.name
json.product_name wishlist.menu_product.product.name
json.local_name wishlist.menu_product.product.local_name 
json.product_hsn_code wishlist.menu_product.product.hsn_code
json.product_basic_unit wishlist.menu_product.product.basic_unit
_image_size = "thumb"
_image_size = params[:image_size] if params[:image_size].present?
_image = wishlist.menu_product.product.product_images.first
_image_url = _image.present? ? "#{_image.image.url(:"#{_image_size}")}" : ""
json.product_image _image.present? ? "#{_image.image_file_name}" : ""
json.product_image_url _image_url
json.product_type wishlist.menu_product.product.product_type
json.product_callorie wishlist.menu_product.product.callorie
json.product_description wishlist.menu_product.product.short_description
# Adding product tags
json.product_tags wishlist.menu_product.product.tags do |tag|
  json.extract! tag, :id, :name, :status, :tag_type, :color
  _image_size = "thumb"
	_image_url = tag.icon.present? ? "#{tag.icon.url(:"#{_image_size}")}" : ""
	json.tag_icon tag.icon.present? ? "#{tag.icon_file_name}" : ""
	json.product_image_url _image_url
end