module DeliveryReportsHelper
	def fetch_product_name(id)
		Product.find(id)
	end
	def fetch_product_unit(id)
		product=Product.find(id)
		unit_name=ProductUnit.select(:name).where("product_basic_unit_id=?",product.basic_unit_id).first
		return unit_name.name
	end
end

