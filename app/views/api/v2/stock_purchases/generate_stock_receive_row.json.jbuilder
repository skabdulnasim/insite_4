json.data do 
	json.product @product
	json.product_sku @product_sku
	json.configurations do 
		json.retail_menu @retail_menu_conf
		json.perc_on_landing @perc_on_landing_conf
		json.auto_generate_sku @auto_generate_sku_conf
		json.stock_expiry_date @stock_expiry_date
		json.input_tax_config @input_tax_config
		json.stock_description @stock_description
	end
	json.sales_percentages @percentages
	json.pom_id @pom_id
	json.product_unit_name @product_unit_name
end