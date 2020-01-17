module Api
	module V2
		class DeliveryBoysController < ApplicationController

			api :POST, '/api/v2/delivery_boys/sign_in', "To delivery boy sign in ( * Make sure developer app must created.)."
      param :email_id, String, :required => true, :desc => "Email ID of delivery boy."
      param :password, String, :required => true, :desc => "Password of delivery boy."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
			def sign_in
				delivery_boy = DeliveryBoy.find_by_email(params[:email_id])
				developer_app=DeveloperApp.last
				user=User.first
		    if delivery_boy && delivery_boy.authenticate(params[:password])
		      # log_in delivery_boy
		      render json: {:status=>'ok', :message => {:simple_message=>"Delivery boy successfully logged in.", :internal_message=>"Delivery boy successfully logged in."}, :data=>{ :app_id=>developer_app.id, :app_secret=>Base64.decode64(developer_app.app_secret), :user_email=>user.email, :delivery_boy=>delivery_boy, :delivery_boy_units=>delivery_boy.units}}
		      #render json: delivery_boy.to_json(:include => :units), :app_id=>developer_app.id, :app_secret=>developer_app.app_secret
		    else
		      render json: {:status=>'error.', :message => {:simple_message=>"Invalid delivery boy username or password.", :internal_message=>"Invalid delivery boy username or password."}}
		    end
			end
		end
	end
end