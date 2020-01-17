module Api
	module V2
		class TagsController < ApplicationController
			api :GET, '/api/v2/tags', "List of all tags. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			def index
				@tags = Tag.where("status=?","active")
			end 
		end
	end
end