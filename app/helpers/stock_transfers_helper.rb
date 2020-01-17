module StockTransfersHelper
	def fetch_product_bins(product_id)
		bins  = BinProduct.where("product_id=?",product_id).select("bin_unique_id,product_quantity")
		if bins.present?
			return bins
		else
			return false
		end
	end
	def get_product_input_unit(product)
		puts product.inspect
		product.input_units.each do |input_unit|
			puts input_unit.inspect
		end
	end
end

