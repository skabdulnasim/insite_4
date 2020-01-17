module SalesPersonsHelper
	def get_day_average user
		average_per_day = user.resources.count.to_f / UserResource.select("DISTINCT(day)").by_user(user.id).count.to_f
		if average_per_day.nan?
      average_per_day = 0
    end
		_per_day = average_per_day.is_a? Integer
		if _per_day == false
			"#{average_per_day.to_i}" " +"
		else
			average_per_day.to_i		
		end	
	end

	def get_day_count user
		user.user_resources.by_day(Date.today.strftime("%A")).count
	end

	def get_resource_count user
		content_tag(:span, user.resources.count, :class => 'm-label orange')
	end

	def get_complete_percentage user
		today_resource_count = user.user_resources.by_day(Date.today.strftime("%A")).count
		@today_visiting_resource = VisitingHistory.select("resource_id").by_user(user.id).today.by_day(Date.today.strftime("%A"))
		@today_visiting_resource = @today_visiting_resource.uniq { |p| p.resource_id }
		today_visiting_resource_count = @today_visiting_resource.count
		#today_visiting_resource_count = user.visiting_histories.by_day(Date.today.strftime("%A")).count
		if today_visiting_resource_count == 0
			visting_complited = 0
		else	
			visting_complited = (today_visiting_resource_count.to_f / today_resource_count.to_f) * 100
		end	
	end

	
end
