class SessionsController < ApplicationController
  def new
  end
  def create
    delivery_boy = DeliveryBoy.find_by_email(params[:email_id])
    if delivery_boy && delivery_boy.authenticate(params[:password])
      log_in delivery_boy
      respond_to do |format|
        format.json { render json: delivery_boy }
      end
    else
      respond_to do |format|
        format.json { render json: "error" }
      end
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
