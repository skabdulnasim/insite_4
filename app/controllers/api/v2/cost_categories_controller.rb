module Api
  module V2
    class CostCategoriesController < ApplicationController
       ### => API Documentation (APIPIE) for 'show' action
      api :GET, '/api/v2/cost_categories', "API to fetch cost categories."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      formats ['json']

      # show all cost categories
      def index
        @cost_categories = CostCategory.all
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
    end
  end
end
