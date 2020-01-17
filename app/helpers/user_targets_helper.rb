module UserTargetsHelper
	def calculate_target_and_due_amount(own_target)
		if own_target.target_type == "by_product"
			own_target_amount = own_target.user_target_products.sum(:target_quantity)
			due_target_amount = own_target_amount
			if own_target.child_targets.present? 
				child_targets = own_target.child_targets.map{|c_t| c_t.user_target_products}.flatten
				child_target_amount = 0
				child_targets.each do |child_target|
					child_target_amount += child_target.target_quantity
				end
				due_target_amount = own_target_amount - child_target_amount
			else
				if own_target.resource_targets.present?
					resource_targets_products = own_target.resource_targets.map{|r_t| r_t.user_target_products}.flatten
					resource_target_amount = 0
					resource_targets_products.each do |res_target_product|
						resource_target_amount += res_target_product.target_quantity
					end
					due_target_amount = own_target_amount - resource_target_amount
				end
			end
		else
			own_target_amount = own_target.target_amount
			due_target_amount = own_target_amount
			due_target_amount = own_target.child_targets.present? ? own_target.target_amount - own_target.child_targets.sum(:target_amount) : own_target.target_amount
		end
		return [own_target_amount,due_target_amount]
	end
	def child_user_targets(user_obj,parent_target_id)
		child_target = user_obj.own_targets.by_parent_id(parent_target_id).first
		return child_target
	end
	def resource_target(resource_obj,parent_target_id)
		resource_target = resource_obj.resource_targets.by_user_target_id(parent_target_id).first
		return resource_target
	end
	def user_target_product(target_obj)
		target_obj.user_target_products.each do |target_product|
			concat (content_tag(:div, class: ["collection-item", "produc_collections", "collection_product_#{target_product.product_id}_#{target_obj.child_user.id}"]) {
				concat (label_tag(target_product.product.name))
        concat(content_tag(:input,'',:name =>"user_products[user_id_#{target_obj.child_user.id}][][product_id]", :type => 'hidden', :value=>target_product.product_id))
        concat(content_tag(:input,'',:name =>"user_products[user_id_#{target_obj.child_user.id}][][target_quantity]", :type => 'number', :value=>target_product.target_quantity))
				concat (label_tag(target_product.product.basic_unit))
			})
		end
	end
	def resource_target_product(resource_target_obj)
		resource_target_obj.user_target_products.each do |target_product|
			concat (content_tag(:div, class: ["collection-item", "produc_collections", "collection_product_#{target_product.product_id}_#{resource_target_obj.resource_id}"]) {
				concat (label_tag(target_product.product.name))
        concat(content_tag(:input,'',:name =>"user_products[resource_id_#{resource_target_obj.resource_id}][][product_id]", :type => 'hidden', :value=>target_product.product_id))
        concat(content_tag(:input,'',:name =>"user_products[resource_id_#{resource_target_obj.resource_id}][][target_quantity]", :type => 'number', :value=>target_product.target_quantity))
				concat (label_tag(target_product.product.basic_unit))
			})
		end
	end
end

