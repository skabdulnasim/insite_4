module Api
  module V2
    class ApprovalsController < ApplicationController
    	def update_approval
        @approval = Approval.find_by_approvable_id_and_approvable_type_and_role_id(params[:approvable_id], params[:approvable_type], params[:role_id])
        if @approval.update_attributes(:user_id => params[:user_id], :is_approve => params[:is_approve], :reason => params[:reason])
          @approval.reload
        end  
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
    end
  end
end