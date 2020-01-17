class SetUserTargetsForIfb < ActiveRecord::Migration
  def change
  # 	# {"user_target"=>{"is_approved"=>"0", "target_type"=>"by_amount", "duration"=>"quaterly", "from_date"=>"2019-04-01", "to_date"=>"2019-06-30"}, "commit"=>"Save Target", "target_month"=>"", "checked_child_users"=>["16", "24"], "target_amount_16"=>"2000", "parent_user_16"=>"1", "parent_target_id_16"=>"", "target_id_16"=>"", "target_amount_24"=>"1000", "parent_user_24"=>"1", "parent_target_id_24"=>"", "target_id_24"=>"", "action"=>"create", "controller"=>"user_targets"}
		# # {"user_target"=>{"is_approved"=>"0", "target_type"=>"by_amount", "duration"=>"quaterly", "from_date"=>"2019-04-01", "to_date"=>"2019-06-30"}, "commit"=>"Save Target", "target_month"=>"", "checked_child_users"=>["39", "37", "38"], "target_amount_39"=>"1000", "parent_user_39"=>"24", "parent_target_id_39"=>"108", "target_id_39"=>"", "target_amount_37"=>"400", "parent_user_37"=>"24", "parent_target_id_37"=>"108", "target_id_37"=>"", "target_amount_38"=>"600", "parent_user_38"=>"24", "parent_target_id_38"=>"108", "target_id_38"=>""}

  # 	# ASM users
  # 	asm_users = User.by_role_name('asm').by_unit(3)
  # 	asm_users.each do |asmu|
  # 		asm_user_target = UserTarget.new
	 #  	asm_user_target.attributes = { :is_approved => "0", :target_type => "by_amount", :duration => "quaterly", :from_date => "2019-04-01", :to_date => "2019-06-30", "target_amount" => "10000000" }
  # 		asm_user_target.child_user_id = asmu.id
  # 		asm_user_target.parent_user_id = asmu.parent_user_id
  # 		asm_user_target.parent_target = ""
  # 		asm_user_target.save 		
  	
  # 		# DSM users
  # 		dsm_users = asmu.child_users.by_role_name("dsm")
  # 		puts dsm_users
  # 		dsm_users.each do |dsmu|
  # 			puts "dsmu"
  # 			puts dsmu.id
  # 			dsm_user_target = UserTarget.new
		#   	dsm_user_target.attributes = { :is_approved => "0", :target_type => "by_amount", :duration => "quaterly", :from_date => "2019-04-01", :to_date => "2019-06-30", "target_amount" => "1000000" }
	 #  		dsm_user_target.child_user_id = dsmu.id
	 #  		dsm_user_target.parent_user_id = asmu.id
	 #  		dsm_user_target.parent_target = asm_user_target.id
	 #  		dsm_user_target.save

	 #  		# sale_person users
	 #  		sp_users = dsmu.child_users.by_role_name("sale_person")
	 #  		sp_users.each do |spu|
	 #  			# puts "spu"
	 #  			# puts spu.id
	 #  			sp_user_target = UserTarget.new
		# 	  	sp_user_target.attributes = { :is_approved => "0", :target_type => "by_amount", :duration => "quaterly", :from_date => "2019-04-01", :to_date => "2019-06-30", "target_amount" => "10000" }
		#   		sp_user_target.child_user_id = spu.id
		#   		sp_user_target.parent_user_id = dsmu.id
		#   		sp_user_target.parent_target = dsm_user_target.id
		#   		sp_user_target.save

		#   		_user_resources = spu.user_resources.uniq_by(&:resource_id)
		#   		if _user_resources.present?
		#   			_user_resources.each do |ur|
		#   				# puts "ur"
		#   				# puts ur.resource_id
		#   				res_target = ResourceTarget.new
		#   				res_target.resource_id = ur.resource_id
		# 					res_target.target_by = spu.id
		# 					res_target.target_amount = "100"
		# 					res_target.user_target_id = sp_user_target.id
		# 					res_target.from_date = "2019-04-01"
		# 					res_target.to_date = "2019-06-30"
		# 					res_target.target_type = "by_amount"
		# 					res_target.duration = "quaterly"
		#   				res_target.save
		#   			end
		#   		end
		#   	end
  # 		end
  # 	end
  end
end