class ResourceManagementsController < ApplicationController
	include SmartListing::Helper::ControllerExtensions
	helper  SmartListing::Helper
	def index
		unit_arr = Array.new
		unit_arr.push(current_user.unit.id)
		unit_arr = (child_units(unit_arr,current_user.unit))
		@rsources = Resource.by_unit_list(unit_arr).active_only
		@bits = Bit.by_unit_list(unit_arr).order("unit_id ASC")
		@areas = Area.by_unit_list(unit_arr).order("unit_id ASC")
		@zones = Zone.by_unit_list(unit_arr).order("unit_id ASC")
		smart_listing_create(:resources,@rsources,:partial=>"resource_managements/resources_smart_list",default_sort: {created_at: "asc"},page_sizes: [10])
		smart_listing_create(:bits,@bits,:partial=>"resource_managements/bits_smart_list",default_sort: {created_at: "asc"},page_sizes: [10])
		smart_listing_create(:zones,@zones,:partial=>"resource_managements/zones_smart_list",default_sort: {created_at: "asc"},page_sizes: [10])
		smart_listing_create(:areas,@areas,:partial=>"resource_managements/areas_smart_list",default_sort: {created_at: "asc"},page_sizes: [10])
	end
end
