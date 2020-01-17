class DashboardsController < ApplicationController

  layout "materialize_default"
  before_filter :set_module_details
  before_filter :set_timerange, only: [:index]
  
  def index
  end

  def analytics
  end

  def sales
  end

  def inventory
  end

  private
  
  def set_module_details
    @module_id = "dashboard"
    @module_title = "Dashboard"
  end   
end
