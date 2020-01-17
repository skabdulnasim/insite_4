json.extract! resource_type, :id, :name
json.resources resource_type.resources do |resource|
  json.extract! resource, :id, :name, :properties, :unit_id, :section_id, :user_id
  json.resource_type_id resource.resource_type_id
  json.resource_type resource.resource_type.name
  json.resource_state_id resource.resource_state_id 
  json.resource_state_name resource.resource_state.name
  json.availabilities resource.availabilities do |availability|
  	if availability.available_date>= Date.today
    	json.available_date availability.available_date
      json.day_of_week availability.available_date.strftime("%A")
    	json.slot_id availability.slot_id
    	json.slot_title availability.slot.title
      json.slot_start_time availability.slot.start_time
      json.slot_end_time availability.slot.end_time
      json.duration availability.slot.duration
    end	
  end
end