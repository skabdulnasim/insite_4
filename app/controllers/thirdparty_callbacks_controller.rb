class ThirdpartyCallbacksController < ApplicationController
	layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  def index
    @thirdparty_callbacks = ThirdpartyCallback.order("created_at desc")
    @thirdparty_callbacks = @thirdparty_callbacks.filter_by_callback_type(params[:callback_type]) if params[:callback_type].present?
    smart_listing_create :thirdparty_callback, @thirdparty_callbacks, partial: "thirdparty_callbacks/thirdparty_callback_samrtlisting"
  end
end
