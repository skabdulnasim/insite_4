module Api
	module V2
		class BeneficiariesController < ApplicationController
			### => API Documentatation (APIPIE) for 'index' action
			api :GET, 'api/v2/beneficiaries', "list of all beneficiaries"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"      
			param :resource_id, String, :required=> true
			def index
				@beneficiaries = Beneficiary.by_resource_id(params[:resource_id]) if params[:resource_id].present?
				@count = @beneficiaries.count
				@beneficiaries = @beneficiaries.page(params[:page]).per(_per) if params[:page].present?
				@quarter = ((Time.now.month - 1) / 3) + 1
				rescue Exception => e
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
		end
	end
end