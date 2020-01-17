module PackagesHelper

  def load_package_units_tree(package_unit_id)
		package_unit = PackageUnit.find(package_unit_id)
		concat (content_tag(:ul, class: ["timeline","collapse-lg","timeline-hairline"], :style => "margin-top: -14px;") {
			concat (content_tag(:li, class: ["timeline-inverted"]) {
				concat (content_tag(:div, class: ["timeline-circ","circ-xl","blue"]) {
					concat (content_tag(:img, "", :src=>"/assets/icons/package-unit.png", class: [""], :style=>"width:23px;margin-top:3px;"))
				})
				concat (content_tag(:div, class: ["row","m0","timeline-entry","mt30","side-link"]) {
					concat (content_tag(:div, class: ["card","m0","col","width-40-p","pointer"]){
						concat (content_tag(:div, class: ["p5","margin-l-15"]){
							concat (content_tag(:h5, class: ["m0"]){
								concat (content_tag(:div, class: ["font-w-400","font-sz-15"]){
									concat (content_tag(:i, "", class: ["fa","fa-arrow-circle-o-right"]))
									concat(content_tag(:span, "#{package_unit.unit_name}", :class => "margin-l-10"))
								})
								concat (content_tag(:div, class: ["margin-t-10"]){
									concat (content_tag(:i, "", class: ["fa","fa-calendar"]))
									concat(content_tag(:span, "#{package_unit.created_at.strftime("%Y-%m-%d  %I:%M %p")}", :class => "margin-l-10"))
								})
							})
						})	
					})
				})
				package_unit_products = package_unit.package_unit_products
				if package_unit_products.present?
					package_unit_products.each do |pu_product|
						load_package_unit_products_tree(pu_product)
					end
				end
				sub_units = package_unit.sub_package_units
				if sub_units.present?
					sub_units.each do |sub_unit|
						load_package_units_tree(sub_unit.id)
					end
				end
			})
		})  
  end

  def load_package_unit_products_tree(pu_product)
  	concat (content_tag(:ul, class: ["timeline","collapse-lg","timeline-hairline"], :style => "margin-top: -14px;") {
			concat (content_tag(:li, class: ["timeline-inverted"]) {
				concat (content_tag(:div, class: ["timeline-circ","circ-xl","blue"]) {
					concat (content_tag(:i, "local_parking", class: ["material-icons"]))
				})
				concat (content_tag(:div, class: ["row","m0","timeline-entry","mt30","side-link"]) {
					concat (content_tag(:div, class: ["card","m0","col","width-40-p","pointer"]){
						concat (content_tag(:div, class: ["p5","margin-l-15"]){
							concat (content_tag(:h5, class: ["m0"]){
								concat (content_tag(:div, class: ["font-w-400","font-sz-15","col-lg-12"]){
									concat (content_tag(:i, "", class: ["fa","fa-angle-double-right"]))
									_product = Product.find(PackageUnitProduct.find(pu_product).product_id)
									_product_name = _product.package_component.present? ?  _product.package_component.name : _product.name            
									concat(content_tag(:span, "#{_product_name}", :class => "margin-l-10"))
								})
								concat (content_tag(:div, class: ["margin-t-10","col-lg-6"]){
									concat (content_tag(:i, "", class: ["fa","fa-balance-scale"]))
									concat(content_tag(:span, "#{pu_product.quantity} #{pu_product.product.basic_unit}", :class => "margin-l-10"))
								})
								concat (content_tag(:div, class: ["p5","col-lg-6"]){
									if pu_product.production_status == '0'
										concat(content_tag(:span, "Production not started", :class => "badge bg-red text_white"))
									elsif pu_product.production_status == '1'
										concat(content_tag(:span, "Production started", :class => "badge bg-yellow text-black"))
									elsif pu_product.production_status == '2'
										concat(content_tag(:span, "Production completed", :class => "badge bg-green text_white"))
									end
								})
							})
						})
					})
				})
				load_product_ingredients(pu_product.product)
			})
		})
  end

  def load_product_ingredients(product)
  	concat (content_tag(:ul, class: ["timeline","collapse-lg","timeline-hairline"], :style => "margin-top: -14px;") {
			product_compositions = product.product_compositions
			if product_compositions.present?
				product_compositions.each do |composition|
					concat (content_tag(:li, class: ["timeline-inverted"]) {
						concat (content_tag(:div, class: ["timeline-circ","circ-xl","blue"]) {
							concat (content_tag(:i, "", class: ["fa","fa-bold"]))
						})
						concat (content_tag(:div, class: ["row","m0","timeline-entry","mt30","side-link"]) {
							concat (content_tag(:div, class: ["card","m0","col","width-40-p","pointer"]){
								concat (content_tag(:div, class: ["p5","margin-l-15"]){
									concat (content_tag(:h5, class: ["m0"]){
										concat (content_tag(:div, class: ["font-w-400","font-sz-15"]){
											concat (content_tag(:i, "", class: ["fa","fa-angle-right"]))
											_product = Product.find(composition.raw_product_id)
											_product_name = _product.package_component.present? ? _product.package_component.name : composition.raw_product.name         
											concat(content_tag(:span, "#{_product_name}", :class => "margin-l-10"))
											# concat(content_tag(:span, "#{composition.raw_product.name}", :class => "margin-l-10"))
										})
										concat (content_tag(:div, class: ["margin-t-10"]){
											concat (content_tag(:i, "", class: ["fa","fa-balance-scale"]))
											concat(content_tag(:span, "#{composition.inventory_quantity} #{composition.product_unit.short_name}", :class => "margin-l-10"))
										})
									})
								})	
							})
						})
					})
				end
			end
		})
  end

  def get_package_status(production_status)
  	if production_status == '0'
			content_tag(:span, 'Not ready', :class => 'm-label red')
		elsif production_status == '1'
			content_tag(:span, 'Partially ready', :class => 'm-label cyan')
		elsif production_status == '2'
			content_tag(:span, 'Fully ready', :class => 'm-label green')
		else
			content_tag(:span, 'Not ready', :class => 'm-label red')
		end
  end

end