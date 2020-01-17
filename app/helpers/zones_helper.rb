module ZonesHelper
	def is_allocated_to_zone(bit_id)
		has_zone = Bit.where("id=? and zone_id IS NOT NULL",bit_id)
		has_zone.present? ? true : false
	end
end
