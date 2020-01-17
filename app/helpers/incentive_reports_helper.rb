module IncentiveReportsHelper
	def calculate_incentive_amount(user_id,percentage,achivement_range_type,child_ids,from_date,to_date)
		incentive_amount = 0
		user = User.find(user_id)
		@incentive_rules = IncentiveRule.by_role_and_range_type(user.role.id,achivement_range_type) 
    
    @incentive_rules.each do |ir|
    	if percentage.to_f >= ir.achivement_lower_range.to_f && percentage.to_f <= ir.achivement_upper_range.to_f
    		
    		# #########################
    		flag = 0
    		user_target_resource = ResourceTarget.set_target_bys(child_ids).date_range(from_date,to_date)
    		user_target_resource.each do |rt|
    			resource_sale = UserSale.by_resource_id(rt.resource_id).by_recorded_at_between(from_date,to_date)
    			target = rt.target_amount
    			resource_achivment_amount = 0
    			if rt.target_type == "by_product"
    				resource_achivment_amount = resource_sale.sum(:quantity)
    			elsif rt.target_type == "by_amount"
    				resource_achivment_amount = resource_sale.sum(:price_with_tax)
    			end
    			achiv_persent = (resource_achivment_amount.to_f * 100)/target.to_f
    			if !(achiv_persent.to_f >= ir.achivement_lower_range.to_f) # && achiv_persent.to_f <= ir.achivement_upper_range.to_f
            flag = 1
    			end
    		end
    		# #########################

    		if flag == 0
    			incentive_amount = incentive_amount.to_f + ir.incentive_amount.to_f
    		elsif flag == 1
    			incentive_amount = incentive_amount.to_f + ir.avg_incentive_amount.to_f
    		end
    	end
    end
    return incentive_amount
  end
end
