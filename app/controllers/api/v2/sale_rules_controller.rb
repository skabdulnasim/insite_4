module Api
  module V2
    class SaleRulesController < ApplicationController

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/sale_rules', "Get all active rule."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :genaric, String, :required => false, :desc => "Get only genaric type rule."
      param :specific, String, :required => false, :desc => "Get only specific type rule."
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 50 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"

      ### => 'index' API Defination      
      def index
        _per = params[:per] || 50
        @sale_rules = SaleRule.active.valid_till
        @sale_rules = @sale_rules.generic if params[:genaric].present?
        @sale_rules = @sale_rules.specific if params[:specific].present?
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception        
      end

    end
  end
end