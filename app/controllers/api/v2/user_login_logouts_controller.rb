module Api
	module V2
		class UserLoginLogoutsController < ApplicationController
			before_filter :set_timerange, only: [:index]
			before_filter :authenticate_user_with_token!

			# API Documentation (APIPIE) for 'index' action	
			api :GET, '/api/v2/user_login_logouts', "API for user's login logout details report."
			param :unit_id, String, :required=>false, :desc=>"unit_id"
			param :email, String, :required=>true, :desc => "Email ID of user, who is sending request." 
			param :device_id, String, :required=>true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
			param :page, String, :required=>false, :desc => "If `page` parameter is present in requests, this API will response with pagination and by default it will return 10 results"
			param :count, String, :required=>false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 10 results. If you want to define the number of results per ependent on parameter"
			param :from_date, String, :required=>true, :desc => "from_date of login logout report"
			param :to_date, String, :required=>true, :desc => "to_date of login logout report"

			def index
				_per = params[:count] || 10

				# @login_details = UserLoginLogout.by_date_range(current_user.unit.unit_name,current_user.users_role.role.name,@from_datetime,@to_datetime).order("created_at desc") if params[:from_date].present? and params[:to_date].present?

				# @login_details = UserLoginLogout.by_date_range_and_unit_id(params[:unit_id],@from_datetime,@to_datetime).order("created_at desc") if params[:from_date].present? and params[:to_date].present? and params[:unit_id].present?

				@login_details = UserLoginLogout.by_date_range(@from_datetime,@to_datetime).order("created_at desc") if params[:from_date].present? and params[:to_date].present?

				@count = @login_details.count
				@login_details = 	@login_details.page(params[:page]).per(_per) if params[:params].present?

				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present?   
			end
		end
	end
end