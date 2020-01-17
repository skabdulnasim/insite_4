class IncentiveReportsController < ApplicationController
	def index

	end

	def by_target
		# @user_target = UserTarget.by_child_user(current_user.id).by_from_to_date(params[:from_date],params[:to_date])
		# @user_ids = []
		# @user_ids = User.set_user_ids(current_user.id,@user_ids)

		# @user_sale = UserSale.by_recorded_at_between(params[:from_date],params[:to_date]).by_user_ids(@user_ids)
		
		# @users_resources=UserResource.by_users(@user_ids)
	end
end
