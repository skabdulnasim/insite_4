class HlHomeController < ApplicationController
  layout "hungryleopard"
  def index
    @leaf_unit_type = Unittype.maximum("unit_type_priority")
    # @cities = Unit.find(:all, :select => 'DISTINCT city', :conditions=> {unittype_id: @leaf_unit_type}) rails 4 migration comment
    @cities = Unit.where(:unittype_id => @leaf_unit_type).select("DISTINCT(city)")
    #@unit_info = Geocoder.search(request.remote_ip)
    @unit_info = Geocoder.search(request.remote_ip)
  end
end
