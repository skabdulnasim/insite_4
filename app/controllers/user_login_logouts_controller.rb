class UserLoginLogoutsController < ApplicationController
  layout "material"

	before_filter :set_module_details
	before_filter :set_timerange, only: [:by_date]

	include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper


	def by_date
		if current_user.role.name == 'owner'
			@roles = Role.all
      @login_details = UserLoginLogout.by_date_range(@from_datetime,@to_datetime).order("created_at desc")
      @users = User.all
    elsif current_user.role.name == 'dc_manager' || current_user.role.name == 'bill_manager' || current_user.role.name == 'outlet_manager'
      unit_ids = []
      @roles = Role.all - [Role.find_by_name('owner')]
      current_user.unit.children.map { |e| unit_ids.push e.id } if current_user.unit.children.present?
      unit_ids << current_user.unit.id
      @login_details = UserLoginLogout.set_unit_in(unit_ids).by_date_range(@from_datetime,@to_datetime).order("created_at desc")
    	@users = User.set_unit(unit_ids)
    else
    	@login_details = current_user.user_login_logouts.by_date_range(@from_datetime,@to_datetime).order("created_at desc")
    end
    @login_details = @login_details.by_role_name(Role.find(params[:filter_role]).name) if params[:filter_role].present?

		smart_listing_create :user_login_details, @login_details, partial: "user_login_logouts/user_login_details_smartlist", default_sort: {created_at: "desc"}
		respond_to do |format|
			format.html
			format.js
			format.pdf { render :layout => false } 
			format.csv { send_data UserLoginLogout.by_date_user_login_logouts_to_csv(@login_details,@from_datetime,@to_datetime), filename: "user_login_logouts-of-#{params[:from_date]}.csv"}
		end
	end



	private

  def set_module_details
    @module_id = "reports"
    @module_title = "Authentication Details"
  end
end
