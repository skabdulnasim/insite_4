module SourcingExecutivesHelper
	def count_todays_allocation(user_id)
		return UserVendor.where("visit_date=? and user_id=?",Date.today,user_id).count
	end
	def count_allocations(user_id)
		_count=UserVendor.where("user_id=?",user_id).count
	end
end
