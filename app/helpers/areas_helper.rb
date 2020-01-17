module AreasHelper
	def is_allocated_to_area(zone_id)
		has_area = Zone.where("id=? AND area_id IS NOT NULL",zone_id)
		has_area.present? ? true : false
	end
end
