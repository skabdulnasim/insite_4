module BitsHelper
	def is_allocated_to_bit(resource_id)
		if BitResource.where("resource_id=?",resource_id).present?
			puts "#{resource_id} is present"
			return true
		else
			puts "#{resource_id} is not present"
			return false
		end
	end
end
