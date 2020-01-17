class UserRoleReportsController < ApplicationController
	layout "material"
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

	def index
    if current_user.users_role.role.name == "owner"
  		@user_roles = Role.order('id')
  		smart_listing_create :user_role_report, @user_roles, partial: "user_role_reports/role_permission_smartlisting"
      respond_to do |format|
        format.html # index.html.erb
        format.js
        # format.pdf { render :layout => false } # Add this line
        format.csv { send_data Role.role_permission_csv(@user_roles), filename: "role_permission.csv" }
      end
    end
  end
end
