class VendorProductPricesController < ApplicationController
	
	include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  def index
  	@vendors = current_user.unit.vendors
    @vendors = @vendors.vendor_like(params[:vendor_filter]) if params[:vendor_filter].present?
    @vendors = Vendor.filter_by_product(@vendors,params[:product_filter]) if params[:product_filter].present?
  	@vendors = Vendor.filter_by_approval_status(@vendors,params[:approval_status]) if params[:approval_status].present?

    smart_listing_create :vendor_product_prices, @vendors, partial: "vendor_product_prices/vendor_product_prices_smartlist", default_sort: {id: "desc"}, page_sizes: [10]
  end

  def update_status
  	@vpp = VendorProductPrice.find(params[:vpp_id])
  	@vpp.update_attributes(:status=>params[:status],:viewed_by=>current_user.id) if @vpp.present?
  	VendorProductPrice.send_sms
  	respond_to do |format|
      format.json { render json: @vpp }
    end
  end

end