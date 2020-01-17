class ErrorsController < ApplicationController
  skip_before_filter :custom_authentication
  before_filter :set_module_details
  
  def not_found
    render(:status => 404)
  end

  def internal_server_error
    render(:status => 500)
  end  

  private
    def set_module_details
      @module_id = "errors"
      @module_title = "Error"
    end
end
