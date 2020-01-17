class CustomerQueuesController < ApplicationController
  load_and_authorize_resource
	include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  def index
  	_current_outlet = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
  	@customer_queues = CustomerQueue.order('id desc')
    @customer_queues = @customer_queues.by_unit(_current_outlet)
		@customer_queues = @customer_queues.set_slot_id_in(params[:slot_id]) if params[:slot_id].present?
  	@customer_queues = @customer_queues.by_is_preauth(params[:is_preauth]) if params[:is_preauth].present?
  	@customer_queues = @customer_queues.is_reserved(params[:is_reserved]) if params[:is_reserved].present?

  	smart_listing_create :customer_queues, @customer_queues, partial: "customer_queues/customer_queues_smartlist", default_sort: {id: "desc"}
  	respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @customer_queues }
    end
  end
end