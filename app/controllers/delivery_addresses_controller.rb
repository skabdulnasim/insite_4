class DeliveryAddressesController < ApplicationController
	layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

	before_filter :set_module_details

  def index
    # puts params[:filter]
    @delivery_address = DeliveryAddress.order("id desc") 
    @delivery_address = @delivery_address.search_by_address(params[:filter]) if params[:filter].present?
    smart_listing_create :delivery_address, @delivery_address, partial: "delivery_addresses/delivery_address_smartlist", default_sort: {id: "desc"}
    respond_to do |format|
      format.html
      format.json { render json: @delivery_address }
      format.js 
    end
  end

  def show
    @delivery_address = DeliveryAddress.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @delivery_address }
    end
  end

  def edit
    @delivery_address = DeliveryAddress.find(params[:id])
  end

  def create
    @delivery_address = DeliveryAddress.new(params[:delivery_address])
    unit_ids = params['unit_ids']
    respond_to do |format|
      check_addr = DeliveryAddress.check_address(@delivery_address.pincode)
      if !check_addr.present?
        @delivery_address.save and DeliveryAddressesUnit.save_unit_delivery(@delivery_address.id, unit_ids)
        format.html { redirect_to delivery_addresses_url, notice: 'Address was successfully created.' }
        format.json {head :no_content}
  		else
  			format.html { redirect_to new_delivery_address_url, alert: 'Address alredy present.' }
  			format.json { render json: @delivery_address.errors, status: :unprocessable_entity }
  		end
  	end
  end

  def update
    @delivery_address = DeliveryAddress.find(params[:id])
    unit_ids = params['unit_ids']
    # puts params[:id]
    puts unit_ids
    respond_to do |format|
      addr = DeliveryAddressesUnit.where('delivery_address_id =?', params[:id])
      if addr.destroy_all and @delivery_address.update_attributes(delivery_address) and DeliveryAddressesUnit.save_unit_delivery(@delivery_address.id, unit_ids)
        format.html { redirect_to @delivery_address, notice:'Address was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @delivery_address.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
  	@delivery_address = DeliveryAddress.new
  end

  def fetch_address_details
    @address_info = Geocoder.search(params[:address])
    puts @address_info.first.inspect
    @delivery_details = {}
    if @address_info
      @address_info.each do |ui|
        @addrs_comp = ui.address_components
        @addrs_comp.each do |ac|
          if ac["types"].include? "postal_code"
            @delivery_details[:pincode] = ac["long_name"]
          end
				end
      end
    end
    respond_to do |format|
      format.json { render json: @delivery_details }
    end
  end

  def destroy
    @delivery_address = DeliveryAddress.find(params[:id])
    @delivery_address.destroy

    respond_to do |format|
      format.html { redirect_to delivery_addresses_url, notice: 'Address was successfully  deleted.' }
      format.json { head :no_content }
    end
  end

  private
  def set_module_details
    @module_id = "reports"
    @module_title = "Delivery Address details"
  end 

  def delivery_address
    params.require(:delivery_address).permit(:address, :pincode)
  end
end
