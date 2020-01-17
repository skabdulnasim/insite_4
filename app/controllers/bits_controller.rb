class BitsController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
	def index
		@bits = Bit.by_unit_id(current_user.unit.id).order("id ASC")
		@bits.each do |bit|
			puts(bit.inspect)
		end
		smart_listing_create :bits, @bits, partial:"bits/bits_smart_list",page_sizes:[2]
	end

	def new
		@bit = Bit.new
		@resources = Resource.order("id ASC")
		bit_resources = BitResource.uniq.pluck(:resource_id)
		@resources = Resource.where("id NOT IN(?)", bit_resources) if bit_resources.present?
  		@resources=@resources.filter_by_string(params[:resource_name]) if params[:resource_name].present?
		smart_listing_create :resources, @resources,partial:"bits/resources_smart_list",page_sizes:[5]
		session[:return_to] ||= request.referer
		respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bits }
      format.js
    end
	end

	def create
		puts params
		@bit = Bit.new(bit_params)
		@bit.unit_id = current_user.unit.id
		respond_to do |format|
			if @bit.save && BitResource.save_bit_resources(@bit.id,params[:resource_ids])
				format.html{redirect_to session.delete(:return_to), :notice=>"Bit created successfully"}
				# redirect_to session.delete(:return_to)
			else
				format.html{render(render action: "new")}
			end
		end
	end
	def edit
		session[:return_to] ||= request.referer
		_bit_resource = BitResource.where("bit_id !=?",params[:id]).pluck(:resource_id)
		@resources = Resource.order("id ASC")
		# _resource_to_ignore = BitResource.where("resource_id NOT IN(?)",_bit_resource).uniq.pluck(:resource_id)
		@resources = Resource.where("id NOT IN(?)", _bit_resource) if _bit_resource.present?
		@resources=@resources.filter_by_string(params[:resource_name]) if params[:resource_name].present?
		@bit = Bit.find(params[:id])
		smart_listing_create :resources, @resources,partial:"bits/resources_smart_list",page_sizes:[5]
	end
	def destroy
		_bit = Bit.find(params[:id])
		_bit.destroy()
		respond_to do |format|
			format.html{redirect_to request.referer, notice: "Bit successfully removed"}
			format.json{head :no_content}
		end
	end
	def update
		@bit = Bit.find(params[:id])
		respond_to do |format|
			if @bit.update_attributes(bit_params) && BitResource.save_bit_resources(@bit.id,params[:resource_ids])
				format.html{redirect_to session.delete(:return_to),notice:"Bit successfully updated"}
				format.json{head:no_content}
			end
		end
	end
	private
	def bit_params
		params.require(:bit).permit(:name,:parent_bit,:area_descriptions)
	end
end
